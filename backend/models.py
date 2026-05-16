from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(50), default='user')  # 'user', 'principal', 'admin'
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    forms = db.relationship('Form', backref='creator', lazy=True)
    signatures = db.relationship('Signature', backref='signer', lazy=True)
    
    def __repr__(self):
        return f'<User {self.username}>'


class Form(db.Model):
    __tablename__ = 'forms'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    content = db.Column(db.Text, nullable=False)  # Form data (JSON or text)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.String(50), default='pending')  # 'pending', 'signed', 'rejected'
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    signatures = db.relationship('Signature', backref='form', lazy=True, cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<Form {self.title}>'


class Signature(db.Model):
    __tablename__ = 'signatures'
    
    id = db.Column(db.Integer, primary_key=True)
    form_id = db.Column(db.Integer, db.ForeignKey('forms.id'), nullable=False)
    signer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    signature_data = db.Column(db.Text, nullable=False) # Base64 encoded image
    signature_file = db.Column(db.String(255))  # File path stored in uploads
    signed_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<Signature {self.form_id} by {self.signer_id}>'
