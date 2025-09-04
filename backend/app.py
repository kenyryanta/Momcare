from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from dotenv import load_dotenv
import os
import sys

# Tambahkan direktori root proyek ke sys.path agar impor modul lancar
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

# Muat variabel dari file .env
load_dotenv()

# --- Inisialisasi Aplikasi Flask ---
app = Flask(__name__)
CORS(app)
app.static_folder = 'static'

# --- Konfigurasi Aplikasi ---

# 1. Konfigurasi Database (Hanya menggunakan SQLAlchemy)
#    Kode ini akan mengambil nilai dari variabel DATABASE_URI di file .env
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URI')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 2. Konfigurasi JWT (JSON Web Token)
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'super-secret-key-default')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 3600  # Token berlaku selama 1 jam

# 3. Konfigurasi Folder Upload
app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static/uploads')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # Batas ukuran file 16MB

# --- Inisialisasi Ekstensi ---

# Inisialisasi SQLAlchemy
# Impor 'db' dari file models Anda, lalu inisialisasi dengan app
from models import db
db.init_app(app)

# Inisialisasi JWT
jwt = JWTManager(app)

# --- Persiapan Direktori & Database ---

# Membuat direktori upload jika belum ada
try:
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'topics'), exist_ok=True)
    print("✅ Direktori upload berhasil dibuat atau sudah ada.")
except Exception as e:
    print(f"❌ Error saat membuat direktori upload: {str(e)}")

# Inisialisasi tabel-tabel database
with app.app_context():
    try:
        # Impor semua model yang tabelnya ingin dibuat
        from models.user import User
        from models.forum import Forum
        from models.comment import Comment
        from models.notification import Notification
        from models.like import Like
        from models.daily_nutrition import DailyNutrition
        from models.daily_nutrition_log import DailyNutritionLog
        
        # Perintah ini akan membuat semua tabel yang belum ada
        db.create_all()
        print("✅ Semua tabel berhasil diinisialisasi.")
    except Exception as e:
        import traceback
        print(f"❌ Error saat menginisialisasi tabel: {str(e)}")
        print(traceback.format_exc())

# --- Pendaftaran Rute (Blueprints) ---

try:
    from routes.auth_routes import auth_bp
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    print("✅ Rute auth berhasil didaftarkan")
    
    from routes.chat_routes import chat_bp
    app.register_blueprint(chat_bp, url_prefix='/api')
    print("✅ Rute chat berhasil didaftarkan")

    from routes.forum_routes import forum_bp
    app.register_blueprint(forum_bp)
    print("✅ Rute forum berhasil didaftarkan")

    from routes.comment_routes import comment_bp
    app.register_blueprint(comment_bp)
    print("✅ Rute comment berhasil didaftarkan")

    from routes.notification_routes import notification_bp
    app.register_blueprint(notification_bp)
    print("✅ Rute notification berhasil didaftarkan")

    from routes.food_detection_routes import food_detection_bp
    app.register_blueprint(food_detection_bp, url_prefix='/food_detection')
    print("✅ Rute food detection berhasil didaftarkan")

    from routes.nutrition_routes import nutrition_bp
    app.register_blueprint(nutrition_bp, url_prefix='/nutrition')
    print("✅ Rute nutrition berhasil didaftarkan")
except ImportError as e:
    print(f"❌ Gagal mendaftarkan blueprint, error impor: {str(e)}")


# --- Rute Dasar & Penanganan Error ---

@app.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/')
def index():
    return jsonify({'message': 'API MomCare Forum berjalan', 'status': 'active'})

@app.errorhandler(404)
def not_found(error):
    return jsonify({'success': False, 'message': 'Endpoint tidak ditemukan'}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({'success': False, 'message': 'Terjadi kesalahan internal pada server'}), 500

# --- Menjalankan Aplikasi ---
if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)