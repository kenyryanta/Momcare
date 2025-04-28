from datetime import datetime
from models import db

class Like(db.Model):
    __tablename__ = 'likes'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    is_like = db.Column(db.Boolean, default=True)  # True untuk like, False untuk dislike
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    forum_id = db.Column(db.Integer, db.ForeignKey('forums.id'), nullable=False)
    
    # Unique constraint: satu user hanya bisa memberikan satu interaksi (like/dislike) per forum
    __table_args__ = (db.UniqueConstraint('user_id', 'forum_id', name='unique_user_forum_like'),)
    
    def to_dict(self):
        return {
            'id': self.id,
            'is_like': self.is_like,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'updated_at': self.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
            'user_id': self.user_id,
            'forum_id': self.forum_id
        }
