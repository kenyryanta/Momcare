import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'default_secret_key')
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'default_jwt_secret')
    JWT_ACCESS_TOKEN_EXPIRES = 3600  # Token berlaku selama 1 jam

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'mysql://{}:{}@{}/{}'.format(
        os.getenv('DB_USER', 'root'),
        os.getenv('DB_PASSWORD', ''),
        os.getenv('DB_HOST', 'localhost'),
        os.getenv('DB_NAME', 'chatbot_db')
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = 'mysql://{}:{}@{}/{}'.format(
        os.getenv('DB_USER'),
        os.getenv('DB_PASSWORD'),
        os.getenv('DB_HOST'),
        os.getenv('DB_NAME')
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig
}
