# 📚 API Documentation

Complete API reference for the Signature Application

## Base URL
```
http://localhost:5000/api
```

## Common Response Format

### Success Response
```json
{
  "message": "Success message",
  "user_id": 1,
  ...
}
```

### Error Response
```json
{
  "error": "Error message"
}
```

---

## 🔐 Authentication Endpoints

### Register User
Create a new user account

**Endpoint**: `POST /auth/register`

**Request**:
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password",
  "role": "user"
}
```

**Response** (201):
```json
{
  "message": "User registered successfully",
  "user_id": 1,
  "username": "john_doe"
}
```

**Errors**:
- `400`: Missing required fields
- `400`: Username already exists

---

### Login User
Authenticate user and get session

**Endpoint**: `POST /auth/login`

**Request**:
```json
{
  "username": "john_doe",
  "password": "secure_password"
}
```

**Response** (200):
```json
{
  "message": "Login successful",
  "user_id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "role": "user"
}
```

**Errors**:
- `401`: Invalid username or password

---

## 📋 Form Endpoints

### Get All Forms
Retrieve all forms in the system

**Endpoint**: `GET /forms`

**Response** (200):
```json
[
  {
    "id": 1,
    "title": "Leave Approval",
    "description": "Student leave request",
    "creator_id": 2,
    "status": "pending",
    "created_at": "2024-03-20T10:30:00"
  },
  {
    "id": 2,
    "title": "Attendance Confirmation",
    "description": "Class attendance",
    "creator_id": 3,
    "status": "signed",
    "created_at": "2024-03-19T14:15:00"
  }
]
```

---

### Create Form
Create a new form that needs signatures

**Endpoint**: `POST /forms`

**Request**:
```json
{
  "title": "Leave Approval Form",
  "description": "Student requests leave",
  "content": "John Doe is requesting leave for personal reasons from March 25-27, 2024",
  "creator_id": 1
}
```

**Response** (201):
```json
{
  "message": "Form created successfully",
  "form_id": 3,
  "title": "Leave Approval Form"
}
```

**Errors**:
- `400`: Missing required fields (title, content, creator_id)
- `500`: Database error

---

### Get Specific Form
Retrieve a form with all its signatures

**Endpoint**: `GET /forms/<form_id>`

**Parameters**:
- `form_id` (path): Integer, ID of the form

**Response** (200):
```json
{
  "id": 1,
  "title": "Leave Approval",
  "description": "Student leave request",
  "content": "John Doe requests 3-day leave...",
  "creator_id": 2,
  "status": "signed",
  "created_at": "2024-03-20T10:30:00",
  "signatures": [
    {
      "id": 1,
      "signer_id": 3,
      "signed_at": "2024-03-21T09:15:00"
    },
    {
      "id": 2,
      "signer_id": 4,
      "signed_at": "2024-03-21T11:45:00"
    }
  ]
}
```

**Errors**:
- `404`: Form not found
- `500`: Database error

---

## ✍️ Signature Endpoints

### Submit Signature
Upload a signature for a form

**Endpoint**: `POST /signatures`

**Request**:
```json
{
  "form_id": 1,
  "signer_id": 3,
  "signature_data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
}
```

**Parameters**:
- `form_id` (integer): ID of the form to sign
- `signer_id` (integer): ID of the user signing
- `signature_data` (string): Base64 encoded PNG image from canvas

**Response** (201):
```json
{
  "message": "Signature uploaded successfully",
  "signature_id": 5,
  "form_id": 1
}
```

**Behavior**:
- Saves signature to database (signature_data column)
- Saves signature as image file (signature_data column stores filename)
- Updates form status to "signed"

**Errors**:
- `404`: Form not found
- `500`: Database error

---

### Get Signature
Retrieve a specific signature

**Endpoint**: `GET /signatures/<signature_id>`

**Parameters**:
- `signature_id` (path): Integer, ID of the signature

**Response** (200):
```json
{
  "id": 5,
  "form_id": 1,
  "signer_id": 3,
  "signature_data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "signed_at": "2024-03-21T09:15:00"
}
```

**Errors**:
- `404`: Signature not found
- `500`: Database error

---

## ❤️ Health Check

### Check API Status
Verify that the API is running

**Endpoint**: `GET /health`

**Response** (200):
```json
{
  "status": "API is running"
}
```

---

## 🔄 Complete Workflow Example

Here's a complete workflow using the API:

### Step 1: Register Users
```bash
# Register Admin
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@school.com",
    "password": "admin123",
    "role": "user"
  }'
# Returns: user_id = 1

# Register Principal
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "principal",
    "email": "principal@school.com",
    "password": "principal123",
    "role": "principal"
  }'
# Returns: user_id = 2
```

### Step 2: Create Form (as Admin)
```bash
curl -X POST http://localhost:5000/api/forms \
  -H "Content-Type: application/json" \
  -d '{
    "title": "School Leave Request",
    "description": "Student absence request form",
    "content": "Date: March 25-27\nReason: Medical appointment",
    "creator_id": 1
  }'
# Returns: form_id = 10
```

### Step 3: Sign Form (as Principal)
```bash
# First, Principal draws signature on canvas and gets base64 image
curl -X POST http://localhost:5000/api/signatures \
  -H "Content-Type: application/json" \
  -d '{
    "form_id": 10,
    "signer_id": 2,
    "signature_data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
  }'
# Returns: signature_id = 1 (signature saved!)
```

### Step 4: Verify Form Status
```bash
curl http://localhost:5000/api/forms/10
# Returns: status = "signed", with signature details
```

---

## 📊 Data Models

### User Model
```
id              (int, primary key)
username        (string, unique)
email           (string, unique)
password        (string)
role            (string) - 'user', 'principal', 'admin'
created_at      (datetime)
```

### Form Model
```
id              (int, primary key)
title           (string)
description     (text)
content         (text)
creator_id      (int, foreign key to User)
status          (string) - 'pending', 'signed', 'rejected'
created_at      (datetime)
updated_at      (datetime)
```

### Signature Model
```
id              (int, primary key)
form_id         (int, foreign key to Form)
signer_id       (int, foreign key to User)
signature_data  (longtext) - base64 image
signature_file  (string) - file path
signed_at       (datetime)
```

---

## 🔑 Request/Response Codes

### Success Codes
- `200 OK`: Request successful
- `201 Created`: Resource created successfully

### Client Error Codes
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Authentication failed
- `404 Not Found`: Resource not found

### Server Error Codes
- `500 Internal Server Error`: Server error

---

## 💾 Signature Data Format

The `signature_data` field contains:
```
data:image/png;base64,<base64_encoded_image>
```

### Example
```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==
```

### To decode in Python:
```python
import base64

# Extract base64 part
base64_part = signature_data.split(',')[1]

# Decode
image_data = base64.b64decode(base64_part)

# Save to file
with open('signature.png', 'wb') as f:
    f.write(image_data)
```

---

## 🚀 Adding New Endpoints

To add a new endpoint, follow this pattern in `app.py`:

```python
@app.route('/api/endpoint', methods=['POST'])
def endpoint_handler():
    try:
        data = request.json
        # Your logic here
        return jsonify({'message': 'success'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

---

## 🔒 Authentication (Future Implementation)

Currently, authentication is basic. To implement JWT:

```python
from flask_jwt_extended import create_access_token, jwt_required

@app.route('/api/auth/login', methods=['POST'])
def login():
    # Verify credentials
    access_token = create_access_token(identity=user.id)
    return jsonify({'access_token': access_token})

@app.route('/api/protected', methods=['GET'])
@jwt_required()
def protected():
    user_id = get_jwt_identity()
    return jsonify({'user_id': user_id})
```

---

**Version**: 1.0.0  
**Last Updated**: March 2024  
**Maintained by**: Your Team
