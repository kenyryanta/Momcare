from flask import Flask, jsonify, send_from_directory
from flask_mysqldb import MySQL
from flask_cors import CORS
from flask_jwt_extended import JWTManager
import os
import sys
from dotenv import load_dotenv
import nltk

# Add project root to sys.path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)
app.static_folder = 'static'

# Database configuration
app.config['MYSQL_HOST'] = os.getenv('DB_HOST', 'localhost')
app.config['MYSQL_USER'] = os.getenv('DB_USER', 'root')
app.config['MYSQL_PASSWORD'] = os.getenv('DB_PASSWORD', 'admin')
app.config['MYSQL_DB'] = os.getenv('DB_NAME', 'forum_db')
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URI', 
    f"mysql://{os.getenv('DB_USER', 'root')}:{os.getenv('DB_PASSWORD', 'admin')}@{os.getenv('DB_HOST', 'localhost')}/{os.getenv('DB_NAME', 'forum_db')}")
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize MySQL
mysql = MySQL(app)

# Import db from models and initialize it with the app
from models import db
db.init_app(app)  # Initialize ONLY ONCE

# JWT configuration
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'super-secret-key')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 3600
jwt = JWTManager(app)

# Upload folder configuration
app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static/uploads')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

# Create upload directories
try:
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'topics'), exist_ok=True)
    print("✅ Direktori upload berhasil dibuat")
except Exception as e:
    print(f"❌ Error saat membuat direktori upload: {str(e)}")
# ================== INISIALISASI MODEL USER ================== 
# try:
#     # Import models satu per satu
#     from models.user import User
    
#     with app.app_context():
#         # Sambungkan instance MySQL ke model User
#         User.mysql = mysql
        
#         # Buat tabel users
#         User.create_table()
        
#         print("✅ Tabel users berhasil diinisialisasi")
        
# except Exception as e:
#     print(f"❌ Error saat inisialisasi tabel users: {str(e)}")
# Initialize database tables
with app.app_context():
    try:
        # Import all models
        from models.user import User
        from models.forum import Forum
        from models.comment import Comment
        from models.notification import Notification
        from models.like import Like
        from models.daily_nutrition import DailyNutrition
        from models.daily_nutrition_log import DailyNutritionLog
        
        # Create tables
        db.create_all()
        print("✅ Semua tabel berhasil diinisialisasi")
    except Exception as e:
        import traceback
        print(f"❌ Error saat menginisialisasi tabel: {str(e)}")
        print(traceback.format_exc())

# Register blueprints
try:
    from routes.auth_routes import auth_bp
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    print("✅ Rute auth berhasil didaftarkan")
except ImportError as e:
    print(f"❌ Error saat mengimpor auth_routes: {str(e)}")

try:
    from routes.chat_routes import chat_bp
    app.register_blueprint(chat_bp, url_prefix='/api')
    print("✅ Rute chat berhasil didaftarkan")
except ImportError as e:
    print(f"❌ Error saat mengimpor chat_routes: {str(e)}")

try:
    from routes.forum_routes import forum_bp
    app.register_blueprint(forum_bp)
    print("✅ Rute forum berhasil didaftarkan")
except ImportError as e:
    print(f"❌ Error saat mengimpor forum_routes: {str(e)}")

try:
    from routes.comment_routes import comment_bp
    app.register_blueprint(comment_bp)
    print("✅ Rute comment berhasil didaftarkan")
except ImportError as e:
    print(f"❌ Error saat mengimpor comment_routes: {str(e)}")

try:
    from routes.notification_routes import notification_bp
    app.register_blueprint(notification_bp)
    print("✅ Rute notification berhasil didaftarkan")
except ImportError as e:
    print(f"❌ Error saat mengimpor notification_routes: {str(e)}")

try:
    from routes.food_detection_routes import food_detection_bp
    app.register_blueprint(food_detection_bp, url_prefix='/food_detection')
    print("✅ Rute food detection berhasil didaftarkan")    
except ImportError as e:
    print(f"❌ Error saat mengimpor notification_routes: {str(e)}")

try:
    from routes.nutrition_routes import nutrition_bp
    app.register_blueprint(nutrition_bp, url_prefix='/nutrition')
    print("✅ Rute nutrition berhasil didaftarkan")    
except ImportError as e:
    print(f"❌ Error saat mengimpor nutrition_routes: {str(e)}")


# Routes
@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/')
def index():
    return jsonify({'message': 'API Forum berjalan', 'status': 'active'})

@app.errorhandler(404)
def not_found(error):
    return jsonify({'success': False, 'message': 'Endpoint tidak ditemukan'}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'success': False, 'message': 'Terjadi kesalahan server'}), 500

# Run the app
if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
