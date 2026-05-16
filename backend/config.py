import os

class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv(
    'DATABASE_URL',
    'mysql+mysqlconnector://signature_user:signature_pass@localhost:3306/signature_db'
)
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT (for authentication)
    SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
    
    # Upload folder for signatures
    UPLOAD_FOLDER = 'uploads'
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER)
