from flask import Flask, request, jsonify
from flask_cors import CORS
from config import Config
from models import db, User, Form, Signature
import base64
import os
from datetime import datetime

app = Flask(__name__)
app.config.from_object(Config)

# Enable CORS for frontend communication
CORS(app)

# Initialize database
db.init_app(app)

# ============ AUTHENTICATION ROUTES ============

@app.route('/api/auth/register', methods=['POST'])
def register():
    """Register a new user"""
    try:
        data = request.json
        
        if not data or not data.get('username') or not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Missing required fields'}), 400
        
        if User.query.filter_by(username=data['username']).first():
            return jsonify({'error': 'Username already exists'}), 400
        
        user = User(
            username=data['username'],
            email=data['email'],
            password=data['password'],  # In production, hash this!
            role=data.get('role', 'user')
        )
        
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'message': 'User registered successfully',
            'user_id': user.id,
            'username': user.username
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/api/auth/login', methods=['POST'])
def login():
    """Login user"""
    try:
        data = request.json
        
        user = User.query.filter_by(username=data['username']).first()
        
        if not user or user.password != data['password']:  # In production, compare hashed passwords!
            return jsonify({'error': 'Invalid username or password'}), 401
        
        return jsonify({
            'message': 'Login successful',
            'user_id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ============ FORM ROUTES ============

@app.route('/api/forms', methods=['GET'])
def get_forms():
    """Get all forms"""
    try:
        forms = Form.query.all()
        return jsonify([{
            'id': form.id,
            'title': form.title,
            'description': form.description,
            'creator_id': form.creator_id,
            'status': form.status,
            'created_at': form.created_at.isoformat()
        } for form in forms]), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/forms', methods=['POST'])
def create_form():
    """Create a new form that needs signatures"""
    try:
        data = request.json
        
        form = Form(
            title=data['title'],
            description=data.get('description'),
            content=data['content'],
            creator_id=data['creator_id']
        )
        
        db.session.add(form)
        db.session.commit()
        
        return jsonify({
            'message': 'Form created successfully',
            'form_id': form.id,
            'title': form.title
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/api/forms/<int:form_id>', methods=['GET'])
def get_form(form_id):
    """Get a specific form with its signatures"""
    try:
        form = Form.query.get(form_id)
        
        if not form:
            return jsonify({'error': 'Form not found'}), 404
        
        signatures = Signature.query.filter_by(form_id=form_id).all()
        
        return jsonify({
            'id': form.id,
            'title': form.title,
            'description': form.description,
            'content': form.content,
            'creator_id': form.creator_id,
            'status': form.status,
            'created_at': form.created_at.isoformat(),
            'signatures': [{
                'id': sig.id,
                'signer_id': sig.signer_id,
                'signed_at': sig.signed_at.isoformat()
            } for sig in signatures]
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ============ SIGNATURE ROUTES ============

@app.route('/api/signatures', methods=['POST'])
def upload_signature():
    """Upload a signature for a form"""
    try:
        data = request.json
        
        # signature_data is base64 encoded image from canvas
        form_id = data['form_id']
        signer_id = data['signer_id']
        signature_data = data['signature_data']  # Base64 string
        
        # Verify form exists
        form = Form.query.get(form_id)
        if not form:
            return jsonify({'error': 'Form not found'}), 404
        
        # Save signature to database
        signature = Signature(
            form_id=form_id,
            signer_id=signer_id,
            signature_data=signature_data
        )
        
        # Optionally: Save as file too
        if signature_data:
            filename = f"signature_{form_id}_{signer_id}_{datetime.utcnow().timestamp()}.png"
            filepath = os.path.join(Config.UPLOAD_FOLDER, filename)
            
            # Decode base64 and save
            image_data = base64.b64decode(signature_data.split(',')[1])
            with open(filepath, 'wb') as f:
                f.write(image_data)
            
            signature.signature_file = filepath
        
        db.session.add(signature)
        form.status = 'signed'  # Update form status
        db.session.commit()
        
        return jsonify({
            'message': 'Signature uploaded successfully',
            'signature_id': signature.id,
            'form_id': form_id
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/api/signatures/<int:signature_id>', methods=['GET'])
def get_signature(signature_id):
    """Get a signature"""
    try:
        signature = Signature.query.get(signature_id)
        
        if not signature:
            return jsonify({'error': 'Signature not found'}), 404
        
        return jsonify({
            'id': signature.id,
            'form_id': signature.form_id,
            'signer_id': signature.signer_id,
            'signature_data': signature.signature_data,
            'signed_at': signature.signed_at.isoformat()
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ============ HEALTH CHECK ============

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'API is running'}), 200


# ============ ERROR HANDLERS ============

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # Create all tables
    app.run(debug=True, host='0.0.0.0', port=5000)
