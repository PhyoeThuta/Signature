# 📝 Digital Signature Application

A complete web application for collecting digital signatures on forms. Users can create forms that need approval, and authorized signers can sign them digitally on canvas. Everything is stored in a database.

## 🎯 Features

- **User Authentication**: Register and login with different roles (user, principal, admin)
- **Form Management**: Create forms that need signatures
- **Digital Signature Capture**: Draw signatures on an HTML canvas
- **Database Storage**: All forms and signatures stored in MySQL
- **Responsive Design**: Works on desktop and tablet devices
- **Real-time Status**: Track whether forms are pending or signed

## 📋 System Architecture

```
┌─────────────────────┐
│   React Frontend    │ (Port 3000)
│  - Sign Up/Login    │
│  - Create Forms     │
│  - Draw Signatures  │
└──────────┬──────────┘
           │
           │ REST API
           │
┌──────────▼──────────┐
│   Flask Backend     │ (Port 5000)
│  - Auth Endpoints   │
│  - Form API         │
│  - Signature API    │
└──────────┬──────────┘
           │
           │ SQL
           │
┌──────────▼──────────┐
│   MySQL Database    │ (Port 3306)
│  (in Docker)        │
│  - Users Table      │
│  - Forms Table      │
│  - Signatures Table │
└─────────────────────┘
```

## 🛠️ Tech Stack

- **Frontend**: React 18, Axios, React Router
- **Backend**: Flask 2.3, SQLAlchemy, MySQL
- **Database**: MySQL 8.0
- **Containerization**: Docker & Docker Compose

## 📦 Project Structure

```
signature-app/
├── frontend/                 # React Application
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── LoginPage.jsx
│   │   │   ├── RegisterPage.jsx
│   │   │   ├── FormPage.jsx
│   │   │   └── SignaturePage.jsx
│   │   ├── App.jsx
│   │   ├── App.css
│   │   └── index.js
│   └── package.json
│
├── backend/                  # Flask Application
│   ├── app.py              # Main Flask app
│   ├── models.py           # Database models
│   ├── config.py           # Configuration
│   ├── requirements.txt    # Python dependencies
│   └── uploads/            # Stored signature files
│
├── docker-compose.yml      # Docker setup for MySQL
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Node.js 14+ installed
- Python 3.8+ installed

### Step 1: Start MySQL Database

```bash
cd signature-app
docker-compose up -d
```

This starts MySQL on `localhost:3306` with:
- Username: `signature_user`
- Password: `signature_pass`
- Database: `signature_db`

### Step 2: Setup Backend (Flask)

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run Flask server
python app.py
```

Backend runs on `http://localhost:5000`

### Step 3: Setup Frontend (React)

```bash
cd frontend

# Install dependencies
npm install

# Start React development server
npm start
```

Frontend runs on `http://localhost:3000`

## 📖 How to Use

1. **Register**: Sign up with a username, email, password, and role
   - Roles: `user` (regular user), `principal` (approver), `admin`

2. **Create Form**: 
   - Go to Dashboard
   - Click "+ Create New Form"
   - Enter title, description, and form content
   - Click "Create Form"

3. **Sign Document**:
   - Click on a form
   - Review the document content
   - Draw your signature on the canvas
   - Click "Submit Signature"

4. **View Status**:
   - Pending forms show ⏳ status
   - Signed forms show ✓ status

## 📊 Database Schema

### Users Table
```sql
- id (Primary Key)
- username (Unique)
- email (Unique)
- password
- role (user/principal/admin)
- created_at
```

### Forms Table
```sql
- id (Primary Key)
- title
- description
- content
- creator_id (Foreign Key to Users)
- status (pending/signed/rejected)
- created_at
- updated_at
```

### Signatures Table
```sql
- id (Primary Key)
- form_id (Foreign Key to Forms)
- signer_id (Foreign Key to Users)
- signature_data (Base64 image)
- signature_file (File path)
- signed_at
```

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Forms
- `GET /api/forms` - Get all forms
- `POST /api/forms` - Create new form
- `GET /api/forms/<id>` - Get specific form

### Signatures
- `POST /api/signatures` - Submit signature
- `GET /api/signatures/<id>` - Get signature

### Health
- `GET /api/health` - Check API status

## 📝 Example API Calls

### Register
```json
POST /api/auth/register
{
  "username": "principal_john",
  "email": "john@school.com",
  "password": "secure123",
  "role": "principal"
}
```

### Create Form
```json
POST /api/forms
{
  "title": "Leave Approval",
  "description": "Student leave request",
  "content": "John Doe requests leave for 3 days...",
  "creator_id": 1
}
```

### Submit Signature
```json
POST /api/signatures
{
  "form_id": 1,
  "signer_id": 2,
  "signature_data": "data:image/png;base64,iVBOR..."
}
```

## ⚙️ Configuration

### Backend Configuration (config.py)
```python
# Default database (no changes needed if using Docker)
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://signature_user:signature_pass@localhost:3306/signature_db'

# Change SECRET_KEY for production
SECRET_KEY = 'your-secret-key-change-in-production'
```

### Frontend Configuration (src/App.jsx)
```javascript
const API_BASE_URL = 'http://localhost:5000/api';
```

## 🔒 Security Notes

⚠️ **For Development Only** ⚠️

Current implementation has basic security. For production:

1. **Hash Passwords**: Use `bcryptjs` or `Werkzeug` for password hashing
2. **Add JWT Authentication**: Implement JWT tokens for secure API calls
3. **HTTPS**: Enable SSL/TLS
4. **Environment Variables**: Move sensitive data to `.env` files
5. **Rate Limiting**: Add rate limiting to API endpoints
6. **Validation**: Add more input validation
7. **CORS**: Configure CORS properly for production domain

## 🐛 Troubleshooting

### MySQL Connection Error
```
Error: Can't connect to MySQL server
```
**Solution**: Ensure Docker is running
```bash
docker ps  # Check if container is running
docker-compose up -d  # Start containers
```

### Port Already in Use
```
Port 3000/5000/3306 already in use
```
**Solution**: Kill process or use different port
```bash
# Change port in docker-compose.yml, app.py, or package.json
```

### CORS Error
```
Access to XMLHttpRequest blocked by CORS
```
**Solution**: Backend already has CORS enabled. Check:
- Frontend and backend are both running
- API_BASE_URL is correct in React

### Signature Not Saving
- Ensure you draw something on canvas
- Check browser console for errors
- Verify MySQL is running

## 📚 Next Steps to Extend

1. **Email Notifications**: Send emails when forms need signatures
2. **Digital Certificates**: Attach certificates to signatures
3. **Audit Trail**: Log all signature events
4. **Multi-party Signatures**: Require multiple signers
5. **Document Templates**: Pre-made form templates
6. **Signature Verification**: Verify authenticity of signatures
7. **PDF Export**: Generate PDF with embedded signatures
8. **Mobile App**: React Native mobile version

## 📄 License

Open source - free to use and modify

## 🤝 Support

For issues or questions, check:
1. Ensure all services are running (`docker ps`, localhost:5000, localhost:3000)
2. Check browser console for frontend errors
3. Check Flask terminal for backend errors
4. Check MySQL logs: `docker logs signature_db`

---

**Happy Signing! 📝✍️**
