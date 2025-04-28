from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db
from models.comment import Comment
from models.notification import Notification
from utils.validation import validate_comment_data
from datetime import datetime

comment_bp = Blueprint('comment', __name__, url_prefix='/api/comments')

# Mengupdate komentar
@comment_bp.route('/<int:comment_id>', methods=['PUT'])
@jwt_required()
def update_comment(comment_id):
    current_user_id = get_jwt_identity()
    
    # Check if comment exists
    comment = Comment.query.get(comment_id)
    if not comment:
        return jsonify({'message': 'Komentar tidak ditemukan'}), 404
    
    # Check ownership - PERUBAHAN PENTING
    if int(comment.user_id) != int(current_user_id):  # <-- Ganti forum.user_id ke comment.user_id
        return jsonify({'message': 'Anda tidak memiliki izin untuk mengubah komentar ini'}), 403
    
    data = request.get_json()
    
    # Validate comment data
    error = validate_comment_data(data.get('content'))
    if error:
        return jsonify({'message': error}), 400
    
    try:
        comment.content = data.get('content')
        comment.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'message': 'Komentar berhasil diperbarui',
            'comment': comment.to_dict()
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal memperbarui komentar: {str(e)}'}), 500


@comment_bp.route('/<int:comment_id>', methods=['DELETE'])
@jwt_required()
def delete_comment(comment_id):
    current_user_id = get_jwt_identity()
    
    # Check if comment exists
    comment = Comment.query.get(comment_id)
    if not comment:
        return jsonify({'message': 'Komentar tidak ditemukan'}), 404
    
    # Check permissions - PERUBAHAN LOGIKA
    from models.forum import Forum
    forum = Forum.query.get(comment.forum_id)
    
    is_comment_owner = int(comment.user_id) == int(current_user_id)
    is_forum_owner = forum and int(forum.user_id) == int(current_user_id)
    
    # Check if user is admin
    from models.user import User
    user = User.query.get(current_user_id)
    is_admin = user and user.is_admin if user else False
    
    # Jika bukan pemilik komentar, pemilik forum, atau admin
    if not is_comment_owner and not is_forum_owner and not is_admin:
        return jsonify({'message': 'Anda tidak memiliki izin untuk menghapus komentar ini'}), 403
    
    try:
        # Hapus notifikasi terkait komentar
        Notification.query.filter_by(comment_id=comment_id).delete()
        
        db.session.delete(comment)
        db.session.commit()
        
        return jsonify({'message': 'Komentar berhasil dihapus'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal menghapus komentar: {str(e)}'}), 500

