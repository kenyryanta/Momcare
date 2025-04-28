# models/__init__.py
from flask_sqlalchemy import SQLAlchemy

# Inisialisasi db tanpa app (akan diinisialisasi nanti dengan init_app)
db = SQLAlchemy()


