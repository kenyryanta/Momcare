# models/topic.py
from datetime import datetime
from flask import current_app
import os

# Import db akan diinjeksi dari app.py
db = None

class Topic:
    # Nama tabel dan inisialisasi variabel
    TABLE_NAME = 'topics'
    
    def __init__(self, id=None, title=None, content=None, image_path=None, forum_id=None, 
                 user_id=None, status='active', view_count=0, created_at=None, updated_at=None):
        self.id = id
        self.title = title
        self.content = content
        self.image_path = image_path
        self.forum_id = forum_id
        self.user_id = user_id
        self.status = status
        self.view_count = view_count
        self.created_at = created_at or datetime.now()
        self.updated_at = updated_at or datetime.now()
    
    @classmethod
    def create_table(cls):
        """Membuat tabel topics jika belum ada."""
        cursor = db.engine.execute(f"""
        CREATE TABLE IF NOT EXISTS {cls.TABLE_NAME} (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            image_path VARCHAR(255) NULL,
            forum_id INT NOT NULL,
            user_id INT NOT NULL,
            status ENUM('active', 'inactive', 'pending_moderation', 'rejected') DEFAULT 'active',
            view_count INT DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (forum_id) REFERENCES forums(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """)
        return True
    
    @classmethod
    def get_by_id(cls, topic_id):
        """Mendapatkan topik berdasarkan ID."""
        query = f"SELECT * FROM {cls.TABLE_NAME} WHERE id = %s"
        result = db.engine.execute(query, (topic_id,)).fetchone()
        
        if result:
            # Increment view count
            db.engine.execute(
                f"UPDATE {cls.TABLE_NAME} SET view_count = view_count + 1 WHERE id = %s", 
                (topic_id,)
            )
            
            return cls(**dict(result))
        return None
    
    @classmethod
    def get_all(cls, limit=10, offset=0, forum_id=None, status='active'):
        """Mendapatkan semua topik dengan filter opsional."""
        query = f"SELECT * FROM {cls.TABLE_NAME} WHERE status = %s"
        params = [status]
        
        if forum_id:
            query += " AND forum_id = %s"
            params.append(forum_id)
        
        query += " ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])
        
        results = db.engine.execute(query, params).fetchall()
        return [cls(**dict(row)) for row in results]
    
    @classmethod
    def count(cls, forum_id=None, status='active'):
        """Menghitung jumlah topik dengan filter opsional."""
        query = f"SELECT COUNT(*) as count FROM {cls.TABLE_NAME} WHERE status = %s"
        params = [status]
        
        if forum_id:
            query += " AND forum_id = %s"
            params.append(forum_id)
        
        result = db.engine.execute(query, params).fetchone()
        return result['count'] if result else 0
    
    @classmethod
    def get_latest(cls, limit=5, status='active'):
        """Mendapatkan topik terbaru."""
        query = f"""
        SELECT t.*, u.username as author_name, f.name as forum_name, 
               (SELECT COUNT(*) FROM comments WHERE topic_id = t.id) as comment_count
        FROM {cls.TABLE_NAME} t
        JOIN users u ON t.user_id = u.id
        JOIN forums f ON t.forum_id = f.id
        WHERE t.status = %s
        ORDER BY t.created_at DESC
        LIMIT %s
        """
        results = db.engine.execute(query, (status, limit)).fetchall()
        return [dict(row) for row in results]
    
    @classmethod
    def search(cls, keyword, limit=10, offset=0, status='active'):
        """Mencari topik berdasarkan keyword."""
        query = f"""
        SELECT t.*, u.username as author_name
        FROM {cls.TABLE_NAME} t
        JOIN users u ON t.user_id = u.id
        WHERE t.status = %s AND (t.title LIKE %s OR t.content LIKE %s)
        ORDER BY t.created_at DESC
        LIMIT %s OFFSET %s
        """
        search_term = f"%{keyword}%"
        results = db.engine.execute(query, (status, search_term, search_term, limit, offset)).fetchall()
        return [dict(row) for row in results]
    
    @classmethod
    def create(cls, data):
        """Membuat topik baru."""
        query = f"""
        INSERT INTO {cls.TABLE_NAME} 
        (title, content, image_path, forum_id, user_id, status)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        result = db.engine.execute(
            query, 
            (data['title'], data['content'], data.get('image_path'), 
             data['forum_id'], data['user_id'], data.get('status', 'active'))
        )
        
        topic_id = result.lastrowid
        return cls.get_by_id(topic_id)
    
    @classmethod
    def update(cls, topic_id, data):
        """Mengupdate topik yang ada."""
        # Buat set update string dan parameter values
        update_fields = []
        params = []
        
        for field, value in data.items():
            if field in ['title', 'content', 'image_path', 'status']:
                update_fields.append(f"{field} = %s")
                params.append(value)
        
        if not update_fields:
            return False
        
        update_str = ", ".join(update_fields)
        query = f"UPDATE {cls.TABLE_NAME} SET {update_str} WHERE id = %s"
        params.append(topic_id)
        
        db.engine.execute(query, params)
        return cls.get_by_id(topic_id)
    
    @classmethod
    def delete(cls, topic_id):
        """Menghapus topik."""
        # Pertama dapatkan info gambar untuk dihapus jika ada
        topic = cls.get_by_id(topic_id)
        if topic and topic.image_path:
            # Hapus file gambar
            image_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'topics', topic.image_path)
            if os.path.exists(image_path):
                os.remove(image_path)
        
        # Hapus topik dari database
        query = f"DELETE FROM {cls.TABLE_NAME} WHERE id = %s"
        db.engine.execute(query, (topic_id,))
        return True
    
    @classmethod
    def change_status(cls, topic_id, status):
        """Mengubah status topik (untuk moderasi)."""
        query = f"UPDATE {cls.TABLE_NAME} SET status = %s WHERE id = %s"
        db.engine.execute(query, (status, topic_id))
        return cls.get_by_id(topic_id)
    
    @classmethod
    def get_pending_moderation(cls, limit=10, offset=0):
        """Mendapatkan topik yang perlu dimoderasi."""
        query = f"""
        SELECT t.*, u.username as author_name, f.name as forum_name
        FROM {cls.TABLE_NAME} t
        JOIN users u ON t.user_id = u.id
        JOIN forums f ON t.forum_id = f.id
        WHERE t.status = 'pending_moderation'
        ORDER BY t.created_at ASC
        LIMIT %s OFFSET %s
        """
        results = db.engine.execute(query, (limit, offset)).fetchall()
        return [dict(row) for row in results]
    
    def to_dict(self, with_user=False, with_comments=False):
        """Mengonversi objek Topic menjadi dictionary."""
        topic_dict = {
            'id': self.id,
            'title': self.title,
            'content': self.content,
            'image_path': self.image_path,
            'forum_id': self.forum_id,
            'user_id': self.user_id,
            'status': self.status,
            'view_count': self.view_count,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S') if isinstance(self.created_at, datetime) else self.created_at,
            'updated_at': self.updated_at.strftime('%Y-%m-%d %H:%M:%S') if isinstance(self.updated_at, datetime) else self.updated_at
        }
        
        # Tambahkan data user jika diminta
        if with_user:
            from models.user import User
            user = User.get_by_id(self.user_id)
            if user:
                topic_dict['user'] = {
                    'id': user.id,
                    'username': user.username
                }
        
        # Tambahkan data komentar jika diminta
        if with_comments:
            from models.comment import Comment
            comments = Comment.get_by_topic_id(self.id)
            topic_dict['comments'] = [comment.to_dict(with_user=True) for comment in comments]
            topic_dict['comment_count'] = len(comments)
        
        return topic_dict
