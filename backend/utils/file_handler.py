import os
import uuid
from werkzeug.utils import secure_filename
from flask import current_app

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def save_image(file):
    """
    Menyimpan file gambar ke direktori upload
    
    Args:
        file: FileStorage object dari flask
    
    Returns:
        str: Path relatif ke file yang tersimpan (untuk disimpan di database)
             None jika gagal menyimpan
    """
    if file and allowed_file(file.filename):
        # Amankan nama file
        filename = secure_filename(file.filename)
        
        # Tambahkan UUID untuk menghindari nama file yang sama
        unique_filename = f"{uuid.uuid4().hex}_{filename}"
        
        # Simpan file
        upload_folder = current_app.config['UPLOAD_FOLDER']
        file_path = os.path.join(upload_folder, unique_filename)
        
        # Buat direktori jika belum ada
        os.makedirs(upload_folder, exist_ok=True)
        
        file.save(file_path)
        return unique_filename
    
    return None

def delete_image(filename):
    """
    Menghapus file gambar dari direktori upload
    
    Args:
        filename: Nama file yang akan dihapus
    
    Returns:
        bool: True jika berhasil, False jika gagal
    """
    try:
        file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
        if os.path.exists(file_path):
            os.remove(file_path)
            return True
    except Exception as e:
        print(f"Error deleting file: {str(e)}")
    
    return False
