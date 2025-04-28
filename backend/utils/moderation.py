import re
from flask import current_app
from models.forum import Forum
from models.comment import Comment

def check_content(content):
    """
    Memeriksa konten untuk kata-kata terlarang
    
    Args:
        content: Teks yang akan diperiksa
    
    Returns:
        bool: True jika konten mengandung kata terlarang
    """
    # Load forbidden words from file
    try:
        with open(current_app.config['FORBIDDEN_WORDS_FILE'], 'r') as file:
            forbidden_words = [line.strip() for line in file.readlines()]
    except:
        # Fallback to default list if file not found
        forbidden_words = [
            "kata_terlarang_1",
            "kata_terlarang_2"
        ]
    
    # Convert content to lowercase for case-insensitive checking
    content_lower = content.lower()
    
    # Check for forbidden words
    for word in forbidden_words:
        if word and re.search(r'\b' + re.escape(word) + r'\b', content_lower):
            return True
    
    return False

def auto_moderate_forum(forum_id):
    """
    Moderasi otomatis untuk forum
    
    Args:
        forum_id: ID forum yang akan dimoderasi
    
    Returns:
        bool: True jika forum dimoderasi (dihapus), False jika tidak
    """
    forum = Forum.query.get(forum_id)
    if not forum:
        return False
    
    # Check title and description
    if check_content(forum.title) or check_content(forum.description):
        # Flag forum for moderation or take action
        return True
    
    return False

def auto_moderate_comment(comment_id):
    """
    Moderasi otomatis untuk komentar
    
    Args:
        comment_id: ID komentar yang akan dimoderasi
    
    Returns:
        bool: True jika komentar dimoderasi (dihapus), False jika tidak
    """
    comment = Comment.query.get(comment_id)
    if not comment:
        return False
    
    # Check content
    if check_content(comment.content):
        # Flag comment for moderation or take action
        return True
    
    return False
