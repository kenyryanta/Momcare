from datetime import datetime
from models import db
from utils.auth_utils import hash_password, verify_password

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_admin = db.Column(db.Boolean, default=False)  # Tambahan untuk fitur admin berdasarkan sequence diagram
    
    # Relationships berdasarkan sequence diagram dan struktur folder
    forums = db.relationship('Forum', backref='author', lazy=True, cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='author', lazy=True, cascade='all, delete-orphan')
    likes = db.relationship('Like', backref='user', lazy=True, cascade='all, delete-orphan')
    notifications = db.relationship('Notification', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def __init__(self, id=None, username=None, email=None, password=None, created_at=None, is_admin=False):
        """Inisialisasi objek User"""
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.created_at = created_at or datetime.utcnow()
        self.is_admin = is_admin
    
    @classmethod
    def create(cls, username, email, password):
        """Membuat user baru dengan password terenkripsi"""
        try:
            hashed_password = hash_password(password)
            new_user = cls(
                username=username,
                email=email,
                password=hashed_password
            )
            db.session.add(new_user)
            db.session.commit()
            return new_user
        except Exception as e:
            db.session.rollback()
            print(f"❌ Gagal membuat user: {str(e)}")
            raise
    
    @classmethod
    def find_by_email(cls, email):
        """Mencari user berdasarkan email"""
        return cls.query.filter_by(email=email).first()
    
    @classmethod
    def find_by_username(cls, username):
        """Mencari user berdasarkan username"""
        return cls.query.filter_by(username=username).first()
    
    @classmethod
    def update_user(cls, user_id, **kwargs):
        """Mengupdate data user"""
        try:
            user = cls.query.get(user_id)
            if not user:
                return False
                
            for key, value in kwargs.items():
                if hasattr(user, key):
                    setattr(user, key, value)
            
            db.session.commit()
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Gagal update user: {str(e)}")
            raise
    
    @classmethod
    def delete_user(cls, user_id):
        """Menghapus user"""
        try:
            user = cls.query.get(user_id)
            if not user:
                return False
                
            db.session.delete(user)
            db.session.commit()
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Gagal menghapus user: {str(e)}")
            raise
    
    def verify_password(self, password):
        """Memverifikasi password pengguna."""
        return verify_password(self.password, password)
    
    def to_dict(self):
        """Mengubah objek ke dictionary"""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'is_admin': self.is_admin,
            'created_at': self.created_at.isoformat() if isinstance(
                self.created_at, datetime) else self.created_at
        }
    
    # Metode tambahan untuk kompatibilitas
    @classmethod
    def get_by_id(cls, user_id):
        """Mendapatkan user berdasarkan ID"""
        return cls.query.get(user_id)
    
    @classmethod
    def get_all_users(cls):
        """Mendapatkan semua user"""
        return cls.query.all()
    
    @classmethod
    def count_users(cls):
        """Menghitung jumlah user"""
        return cls.query.count()
    
    def save(self):
        """Menyimpan perubahan pada user"""
        try:
            db.session.add(self)
            db.session.commit()
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Gagal menyimpan user: {str(e)}")
            raise
    
    def __repr__(self):
        """Representasi string dari objek User"""
        return f"<User {self.username}>"
