import re

def validate_email(email):
    pattern = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'
    return re.match(pattern, email) is not None

def validate_password(password):
    if len(password) < 8:
        return False
    if not re.search(r'[A-Z]', password):
        return False
    if not re.search(r'[a-z]', password):
        return False
    if not re.search(r'\d', password):
        return False
    return True

def validate_forum_data(title, description):
    """
    Validasi data forum
    
    Args:
        title: Judul forum
        description: Deskripsi forum
    
    Returns:
        str: Pesan error jika validasi gagal, None jika sukses
    """
    if not title:
        return "Judul forum tidak boleh kosong"
    
    if len(title) < 5:
        return "Judul forum minimal 5 karakter"
    
    if len(title) > 255:
        return "Judul forum maksimal 255 karakter"
    
    if not description:
        return "Deskripsi forum tidak boleh kosong"
    
    if len(description) < 10:
        return "Deskripsi forum minimal 10 karakter"
    
    return None

def validate_comment_data(content):
    """
    Validasi data komentar
    
    Args:
        content: Isi komentar
    
    Returns:
        str: Pesan error jika validasi gagal, None jika sukses
    """
    if not content:
        return "Konten komentar tidak boleh kosong"
    
    if len(content) < 2:
        return "Konten komentar minimal 2 karakter"
    
    if len(content) > 1000:
        return "Konten komentar maksimal 1000 karakter"
    
    return None
