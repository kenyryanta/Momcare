from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db
from models.notification import Notification

notification_bp = Blueprint('notification', __name__, url_prefix='/api/notifications')

# Mendapatkan semua notifikasi untuk pengguna saat ini
@notification_bp.route('', methods=['GET'])
@jwt_required()
def get_user_notifications():
    current_user_id = get_jwt_identity()
    
    # Get unread notifications count
    unread_count = Notification.query.filter_by(user_id=current_user_id, is_read=False).count()
    
    # Get all notifications, with unread first
    notifications = Notification.query.filter_by(user_id=current_user_id) \
                            .order_by(Notification.is_read, Notification.created_at.desc()) \
                            .all()
    
    return jsonify({
        'notifications': [notif.to_dict() for notif in notifications],
        'unread_count': unread_count
    }), 200

# Menandai notifikasi sebagai telah dibaca
@notification_bp.route('/<int:notification_id>/read', methods=['POST'])
@jwt_required()
def mark_notification_read(notification_id):
    current_user_id = get_jwt_identity()
    
    # Check if notification exists and belongs to current user
    notification = Notification.query.filter_by(id=notification_id, user_id=current_user_id).first()
    if not notification:
        return jsonify({'message': 'Notifikasi tidak ditemukan'}), 404
    
    try:
        notification.is_read = True
        db.session.commit()
        
        return jsonify({'message': 'Notifikasi ditandai sebagai telah dibaca'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal memperbarui notifikasi: {str(e)}'}), 500

# Menandai semua notifikasi sebagai telah dibaca
@notification_bp.route('/read-all', methods=['POST'])
@jwt_required()
def mark_all_notifications_read():
    current_user_id = get_jwt_identity()
    
    try:
        Notification.query.filter_by(user_id=current_user_id, is_read=False) \
                   .update({Notification.is_read: True})
        db.session.commit()
        
        return jsonify({'message': 'Semua notifikasi ditandai sebagai telah dibaca'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Gagal memperbarui notifikasi: {str(e)}'}), 500
