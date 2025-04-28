from functools import wraps
from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.user import User

def admin_required(fn):
    """Decorator untuk memastikan pengguna adalah admin"""
    @wraps(fn)
    @jwt_required()
    def wrapper(*args, **kwargs):
        # Dapatkan ID pengguna dari token JWT
        current_user_id = get_jwt_identity()
        
        # Cek apakah pengguna admin
        user = User.get_by_id(current_user_id)
        
        if not user or not user.get('is_admin', False):
            return jsonify({
                'success': False,
                'message': 'Akses ditolak. Hanya admin yang dapat mengakses fitur ini.'
            }), 403
        
        return fn(*args, **kwargs)
    
    return wrapper

def is_admin(user_id):
    """Fungsi helper untuk mengecek apakah user adalah admin"""
    user = User.get_by_id(user_id)
    return user and user.get('is_admin', False)
