import re
import bcrypt
from flask import jsonify
from functools import wraps
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity

def hash_password(password):
    """
    Fungsi untuk menghasilkan hash dari password menggunakan bcrypt
    """
    # Menghasilkan salt dan hash password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(stored_password, provided_password):
    """
    Fungsi untuk memverifikasi password
    """
    return bcrypt.checkpw(provided_password.encode('utf-8'), stored_password.encode('utf-8'))

def validate_email(email):
    """
    Fungsi untuk memvalidasi format email
    """
    email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(email_regex, email) is not None

def validate_password(password):
    """
    Fungsi untuk memvalidasi kekuatan password
    - Minimal 8 karakter
    - Minimal 1 huruf besar
    - Minimal 1 huruf kecil
    - Minimal 1 angka
    """
    if len(password) < 8:
        return False, "Password harus minimal 8 karakter"
    
    if not re.search(r'[A-Z]', password):
        return False, "Password harus mengandung minimal 1 huruf besar"
    
    if not re.search(r'[a-z]', password):
        return False, "Password harus mengandung minimal 1 huruf kecil"
    
    if not re.search(r'[0-9]', password):
        return False, "Password harus mengandung minimal 1 angka"
    
    return True, "Password valid"

def jwt_required_custom(fn):
    """
    Decorator custom untuk memerlukan JWT dengan penanganan error yang lebih baik
    """
    @wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            verify_jwt_in_request()
            return fn(*args, **kwargs)
        except Exception as e:
            return jsonify({"error": "Token tidak valid atau telah kedaluwarsa", "details": str(e)}), 401
    return wrapper

def get_user_from_token():
    """
    Fungsi untuk mendapatkan data user dari token JWT
    """
    try:
        verify_jwt_in_request()
        identity = get_jwt_identity()
        return identity
    except Exception:
        return None
