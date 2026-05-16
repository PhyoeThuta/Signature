# 📝 Digital Signature Application

A complete web application for collecting digital signatures on forms. Users can register, create forms that need approval, and authorized signers can sign them digitally on an HTML canvas. All data is securely stored in a MySQL database.

---

## ✨ Features

- **👤 User Authentication** - Register and login with role-based access (user, principal, admin)
- **📋 Form Management** - Create, edit, and manage forms that require signatures
- **✍️ Digital Signature Capture** - Draw signatures directly on an HTML canvas
- **💾 Database Storage** - All forms and signatures securely stored in MySQL
- **📱 Responsive Design** - Works seamlessly on desktop, tablet, and mobile devices
- **⚡ Real-time Status** - Track form status (pending, signed, completed)
- **☁️ Cloud Deployment** - Ready for Google Cloud Platform (GCP) or local Docker deployment

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│        React Frontend (Nginx)                   │
│        Port: 80/3000                            │
│  - User Interface                               │
│  - Form Creation                                │
│  - Signature Canvas                             │
└──────────────┬──────────────────────────────────┘
               │ REST API
               ▼
┌─────────────────────────────────────────────────┐
│        Flask Backend (Python)                   │
│        Port: 5000                               │
│  - Authentication                               │
│  - Form APIs                                    │
│  - Signature Processing                         │
└──────────────┬──────────────────────────────────┘
               │ SQL
               ▼
┌─────────────────────────────────────────────────┐
│        MySQL Database                           │
│        Port: 3306                               │
│  - Users                                        │
│  - Forms                                        │
│  - Signatures                                   │
└─────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

### Frontend
- **React** 18 - UI framework
- **Axios** - HTTP client
- **React Router** - Client-side routing
- **react-signature-canvas** - Signature drawing
- **Nginx** - Production web server

### Backend
- **Flask** 2.3 - Python web framework
- **SQLAlchemy** - ORM
- **Flask-CORS** - Cross-origin requests
- **mysql-connector-python** - MySQL driver
- **Python** 3.9+

### Database
- **MySQL** 8.0

### DevOps
- **Docker** & **Docker Compose** - Containerization
- **Kubernetes (GKE)** - Orchestration
- **Google Cloud Platform** - Cloud hosting

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- OR Python 3.9+, Node.js 14+, MySQL 8.0

### Option 1: Run Locally with Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/signature-app.git
cd signature-app

# Start all services
docker-compose up --build

# Application will be available at:
# Frontend: http://localhost
# Backend API: http://localhost:5000
# Database: localhost:3306
```

### Option 2: Run Locally with Python & Node.js

**Backend Setup:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
# Backend runs on http://localhost:5000
```

**Frontend Setup (in new terminal):**
```bash
cd frontend
npm install
npm start
# Frontend runs on http://localhost:3000
```

---

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Forms
- `GET /api/forms` - Get all forms
- `POST /api/forms` - Create new form
- `GET /api/forms/<id>` - Get specific form
- `PUT /api/forms/<id>` - Update form
- `DELETE /api/forms/<id>` - Delete form

### Signatures
- `POST /api/signatures` - Submit signature
- `GET /api/signatures?form_id=<id>` - Get signatures for a form
- `GET /api/signatures/<id>` - Get specific signature

### Health Check
- `GET /api/health` - Backend health status

For complete API documentation, see [API_DOCUMENTATION.md](./md/API_DOCUMENTATION.md)

---

## 📁 Project Structure

```
signature-app/
├── backend/                 # Flask application
│   ├── app.py              # Main app entry point
│   ├── config.py           # Configuration
│   ├── models.py           # Database models
│   ├── requirements.txt     # Python dependencies
│   ├── Dockerfile          # Backend container
│   └── uploads/            # User uploads storage
│
├── frontend/               # React application
│   ├── src/
│   │   ├── App.jsx         # Main React component
│   │   ├── components/     # React components
│   │   │   ├── LoginPage.jsx
│   │   │   ├── RegisterPage.jsx
│   │   │   ├── FormPage.jsx
│   │   │   └── SignaturePage.jsx
│   │   └── index.js        # Entry point
│   ├── package.json        # Node dependencies
│   ├── Dockerfile          # Frontend container
│   └── nginx.conf          # Nginx configuration
│
├── k8s/                    # Kubernetes manifests
│   ├── namespace-config.yaml
│   ├── backend.yaml
│   ├── frontend.yaml
│   ├── mysql.yaml
│   └── ingress.yaml
│
├── md/                     # Documentation
│   ├── README.md
│   ├── API_DOCUMENTATION.md
│   ├── PROJECT_STRUCTURE.md
│   ├── QUICKSTART.md
│   ├── GCP_DEPLOYMENT.md
│   ├── TESTING.md
│   └── TROUBLESHOOTING.md
│
├── docker-compose.yml      # Docker Compose configuration
├── cloudbuild.yaml         # Google Cloud Build config
├── DEPLOYMENT_COMPLETE.md  # Deployment status
└── .gitignore              # Git ignore rules
```

---

## 🌐 Deployment

### Deploy to Google Cloud Platform (GCP)

See [GCP_DEPLOYMENT.md](./md/GCP_DEPLOYMENT.md) for detailed instructions.

**Quick Summary:**
```bash
./deploy-to-gcp.sh
```

### Deploy to Kubernetes Locally

```bash
# Create namespace
kubectl apply -f k8s/namespace-config.yaml

# Deploy all services
kubectl apply -f k8s/

# Check status
kubectl get pods -n signature-app
kubectl get svc -n signature-app
```

---

## 🧪 Testing

See [TESTING.md](./md/TESTING.md) for comprehensive testing guide.

### Quick Test
```bash
# Frontend
cd frontend && npm test

# Backend
cd backend && python -m pytest
```

---

## 🔧 Environment Variables

### Backend (.env)
```
FLASK_ENV=development
DATABASE_URL=mysql+mysqlconnector://root:password@localhost:3306/signature_db
SECRET_KEY=your-secret-key
```

See [backend/.env.example](./backend/.env.example) for template.

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:5000
```

See [frontend/.env.example](./frontend/.env.example) for template.

---

## 🐛 Troubleshooting

Common issues and solutions: [TROUBLESHOOTING.md](./md/TROUBLESHOOTING.md)

---

## 📖 Documentation

- **[API Documentation](./md/API_DOCUMENTATION.md)** - All API endpoints
- **[GCP Deployment Guide](./md/GCP_DEPLOYMENT.md)** - Cloud deployment steps
- **[Docker & Kubernetes Reference](./md/DOCKER_KUBERNETES_SETUP.md)** - Container orchestration
- **[Testing Guide](./md/TESTING.md)** - Testing procedures
- **[Troubleshooting](./md/TROUBLESHOOTING.md)** - Common issues

---

## 👨‍💻 Development

### Prerequisites
- Python 3.9+
- Node.js 14+
- MySQL 8.0
- Docker & Docker Compose

### Getting Started
1. Clone the repository
2. Follow [QUICKSTART.md](./md/QUICKSTART.md)
3. Make your changes
4. Test locally with `docker-compose up`
5. Push to GitHub

---

## 📝 License

This project is open source and available under the MIT License.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 Support

For issues, questions, or suggestions:
1. Check [TROUBLESHOOTING.md](./md/TROUBLESHOOTING.md)
2. Review [API_DOCUMENTATION.md](./md/API_DOCUMENTATION.md)
3. Open a GitHub Issue

---

**Built with ❤️ | Deployed to Google Cloud Platform**
