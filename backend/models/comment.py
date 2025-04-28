from datetime import datetime
from models import db

class Comment(db.Model):
    __tablename__ = 'comments'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    forum_id = db.Column(db.Integer, db.ForeignKey('forums.id'), nullable=False)
    user = db.relationship('User', back_populates='comments')
    # Tambahkan relasi untuk cascade delete
    notifications = db.relationship(
        'Notification', 
        backref='comment', 
        cascade="all, delete-orphan",
        passive_deletes=True
    )
    
    def to_dict(self):
        return {
            'id': self.id,
            'content': self.content,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
            'user_id': self.user_id,
            'forum_id': self.forum_id,
            'username': self.user.username  # Asumsi ada relasi ke User
        }

