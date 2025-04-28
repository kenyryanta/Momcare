from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db
from models.forum import Forum
from models.comment import Comment
from models.like import Like
from models.notification import Notification
from utils.file_handler import save_image, delete_image
from utils.validation import validate_forum_data, validate_comment_data
from utils.auth_middleware import admin_required
from datetime import datetime
import os

forum_bp = Blueprint('forum', __name__, url_prefix='/api/forums')

# Mendapatkan semua forum
@forum_bp.route('', methods=['GET'])
def get_all_forums():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    # Filter by user_id jika ada
    user_id = request.args.get('user_id', type=int)
    query = Forum.query
    
    if user_id:
        query = query.filter_by(user_id=user_id)
    
    # Sorting
    sort_by = request.args.get('sort_by', 'created_at')
    order = request.args.get('order', 'desc')
    
    if sort_by == 'likes':
        # Ini perlu query yang lebih kompleks untuk sorting berdasarkan jumlah like
        # Implementasi sederhana untuk demo
        if order == 'asc':
            query = query.order_by(Forum.id.asc())
        else:
            query = query.order_by(Forum.id.desc())
    else:
        # Default sorting by created_at
        if order == 'asc':
            query = query.order_by(Forum.created_at.asc())
        else:
            query = query.order_by(Forum.created_at.desc())
    
    # Pagination
    forums_page = query.paginate(page=page, per_page=per_page, error_out=False)
    forums = forums_page.items
    
    # Get user info for each forum
    from models.user import User
    
    result = []
    for forum in forums:
        forum_dict = forum.to_dict()
        user = User.query.get(forum.user_id)
        if user:
            forum_dict['username'] = user.username
        result.append(forum_dict)
    
    return jsonify({
        'forums': result,
        'total': forums_page.total,
        'pages': forums_page.pages,
        'current_page': page
    }), 200

# Mendapatkan detail forum
@forum_bp.route('/<int:forum_id>', methods=['GET'])
def get_forum(forum_id):
    forum = Forum.query.get(forum_id)
    
    if not forum:
        return jsonify({'message': 'Forum tidak ditemukan'}), 404
    
    # Get forum info
    forum_dict = forum.to_dict()
    
    # Get user info
    from models.user import User
    user = User.query.get(forum.user_id)
    if user:
        forum_dict['username'] = user.username
    
    # Get comments
    comments = Comment.query.filter_by(forum_id=forum_id).order_by(Comment.created_at.desc()).all()
    comments_list = []
    
    for comment in comments:
        comment_dict = comment.to_dict()
        comment_user = User.query.get(comment.user_id)
        if comment_user:
            comment_dict['username'] = comment_user.username
        comments_list.append(comment_dict)
    
    forum_dict['comments'] = comments_list
    
    # Get user's like status (if user is authenticated)
    current_user_id = None
    try:
        current_user_id = get_jwt_identity()
    except:
        pass
    
    if current_user_id:
        like = Like.query.filter_by(user_id=current_user_id, forum_id=forum_id).first()
        if like:
            forum_dict['user_like_status'] = 'like' if like.is_like else 'dislike'
        else:
            forum_dict['user_like_status'] = None
    
    return jsonify(forum_dict), 200

# Membuat forum baru
@forum_bp.route('', methods=['POST'])
@jwt_required()
def create_forum():
    current_user_id = get_jwt_identity()
    
    # Handle multipart/form-data (dengan gambar) atau application/json
    if 'multipart/form-data' in request.content_type:
        title = request.form.get('title')
        description = request.form.get('description')
        image = request.files.get('image')
        
        # Validasi data forum
        error = validate_forum_data(title, description)
        if error:
            return jsonify({'message': error}), 400
        
        # Save image if provided
        image_path = None
        if image:
            image_path = save_image(image)
            if not image_path:
                return jsonify({'message': 'Gagal menyimpan gambar, format tidak didukung'}), 400
    else:
        data = request.get_json()
        
        # Validasi data forum
        error = validate_forum_data(data.get('title'), data.get('description'))
        if error:
            return jsonify({'message': error}), 400
        
        title = data.get('title')
        description = data.get('description')
        image_path = None  # Tidak ada gambar dalam JSON request
    
    # Buat forum baru
    new_forum = Forum(
        title=title,
        description=description,
        image_path=image_path,
        user_id=current_user_id
    )
    
    try:
        db.session.add(new_forum)
        db.session.commit()
        
        # Return forum data
        forum_dict = new_forum.to_dict()
        
        # Get username
        from models.user import User
        user = User.query.get(current_user_id)
        if user:
            forum_dict['username'] = user.username
        
        return jsonify({
            'message': 'Forum berhasil dibuat',
            'forum': forum_dict
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal membuat forum: {str(e)}'}), 500

@forum_bp.route('/<int:forum_id>', methods=['PUT'])
@jwt_required()
def update_forum(forum_id):
    current_user_id = get_jwt_identity()
    forum = Forum.query.get(forum_id)

    if not forum:
        return jsonify({'message': 'Forum tidak ditemukan'}), 404

    # Debugging: log id user dan owner forum
    print(f"[DEBUG] current_user_id: {current_user_id}, forum.user_id: {forum.user_id}")

    # Gunakan type casting untuk memastikan tipe data sama
    try:
        if int(forum.user_id) != int(current_user_id):
            return jsonify({'message': 'Anda tidak memiliki izin untuk mengubah forum ini'}), 403
    except Exception as e:
        return jsonify({'message': f'Error pada pengecekan user: {str(e)}'}), 500

    # Lanjutkan proses update
    data = request.get_json()
    if not data:
        return jsonify({'message': 'Data tidak ditemukan'}), 400

    if 'title' in data:
        forum.title = data['title']
    if 'description' in data:
        forum.description = data['description']

    try:
        forum.updated_at = datetime.utcnow()
        db.session.commit()
        return jsonify({'message': 'Forum berhasil diperbarui', 'forum': forum.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal memperbarui forum: {str(e)}'}), 500

    

# Menghapus forum
@forum_bp.route('/<int:forum_id>', methods=['DELETE'])
@jwt_required()
def delete_forum(forum_id):
    current_user_id = get_jwt_identity()
    forum = Forum.query.get(forum_id)
    
    if not forum:
        return jsonify({'message': 'Forum tidak ditemukan'}), 404
    
    if int(forum.user_id) != int(current_user_id):
        return jsonify({'message': 'Akses ditolak'}), 403

    try:
        # Hapus notifikasi terkait komentar
        Notification.query.filter(
            Notification.forum_id == forum_id
        ).delete(synchronize_session=False)
        
        # Hapus komentar
        Comment.query.filter_by(forum_id=forum_id).delete()
        
        # Hapus forum
        db.session.delete(forum)
        db.session.commit()
        
        return jsonify({'message': 'Forum berhasil dihapus'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal menghapus: {str(e)}'}), 500

# Menambahkan komentar ke forum
@forum_bp.route('/<int:forum_id>/comments', methods=['POST'])
@jwt_required()
def add_comment(forum_id):
    current_user_id = get_jwt_identity()
    
    # Check if forum exists
    forum = Forum.query.get(forum_id)
    if not forum:
        return jsonify({'message': 'Forum tidak ditemukan'}), 404
    
    data = request.get_json()
    
    # Validate comment data
    error = validate_comment_data(data.get('content'))
    if error:
        return jsonify({'message': error}), 400
    
    # Create new comment
    new_comment = Comment(
        content=data.get('content'),
        user_id=current_user_id,
        forum_id=forum_id
    )
    
    try:
        db.session.add(new_comment)
        db.session.commit()
        
        # Create notification for forum owner if commenter is not the owner
        if forum.user_id != current_user_id:
            from models.user import User
            commenter = User.query.get(current_user_id)
            
            notification = Notification(
                message=f"{commenter.username} mengomentari forum Anda '{forum.title}'",
                user_id=forum.user_id,
                forum_id=forum_id,
                comment_id=new_comment.id
            )
            db.session.add(notification)
            db.session.commit()
        
        # Return comment data with username
        comment_dict = new_comment.to_dict()
        
        # Get username
        from models.user import User
        user = User.query.get(current_user_id)
        if user:
            comment_dict['username'] = user.username
        
        return jsonify({
            'message': 'Komentar berhasil ditambahkan',
            'comment': comment_dict
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal menambahkan komentar: {str(e)}'}), 500

# Mendapatkan semua komentar untuk forum tertentu
@forum_bp.route('/<int:forum_id>/comments', methods=['GET'])
def get_forum_comments(forum_id):
    # Check if forum exists
    forum = Forum.query.get(forum_id)
    if not forum:
        return jsonify({'message': 'Forum tidak ditemukan'}), 404
    
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    comments_page = Comment.query.filter_by(forum_id=forum_id) \
                         .order_by(Comment.created_at.desc()) \
                         .paginate(page=page, per_page=per_page, error_out=False)
    
    comments = comments_page.items
    
    # Get user info for each comment
    from models.user import User
    
    result = []
    for comment in comments:
        comment_dict = comment.to_dict()
        user = User.query.get(comment.user_id)
        if user:
            comment_dict['username'] = user.username
        result.append(comment_dict)
    
    return jsonify({
        'comments': result,
        'total': comments_page.total,
        'pages': comments_page.pages,
        'current_page': page
    }), 200

# Like/unlike forum
@forum_bp.route('/<int:forum_id>/like', methods=['POST'])
@jwt_required()
def toggle_like(forum_id):
    current_user_id = get_jwt_identity()
    
    # Check if forum exists
    forum = Forum.query.get(forum_id)
    if not forum:
        return jsonify({'message': 'Forum tidak ditemukan'}), 404
    
    data = request.get_json()
    is_like = data.get('is_like', True)  # Default to like if not specified
    
    # Check if user already liked/disliked this forum
    existing_like = Like.query.filter_by(user_id=current_user_id, forum_id=forum_id).first()
    
    try:
        if existing_like:
            # If same action (like->like or dislike->dislike), remove the like/dislike
            if existing_like.is_like == is_like:
                db.session.delete(existing_like)
                action = 'dihapus'
            else:
                # If different action (like->dislike or dislike->like), update it
                existing_like.is_like = is_like
                existing_like.updated_at = datetime.utcnow()
                action = 'diubah'
        else:
            # Create new like
            new_like = Like(
                is_like=is_like,
                user_id=current_user_id,
                forum_id=forum_id
            )
            db.session.add(new_like)
            action = 'ditambahkan'
        
        db.session.commit()
        
        # Create notification for forum owner if liker is not the owner
        if forum.user_id != current_user_id:
            from models.user import User
            liker = User.query.get(current_user_id)
            
            like_action = "menyukai" if is_like else "tidak menyukai"
            notification = Notification(
                message=f"{liker.username} {like_action} forum Anda '{forum.title}'",
                user_id=forum.user_id,
                forum_id=forum_id
            )
            db.session.add(notification)
            db.session.commit()
        
        # Get updated like counts
        like_count = Like.query.filter_by(forum_id=forum_id, is_like=True).count()
        dislike_count = Like.query.filter_by(forum_id=forum_id, is_like=False).count()
        
        return jsonify({
            'message': f'{"Like" if is_like else "Dislike"} berhasil {action}',
            'like_count': like_count,
            'dislike_count': dislike_count
        }), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal memproses like/dislike: {str(e)}'}), 500
