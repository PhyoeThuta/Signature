# 🧪 Testing Guide & Workflow Scenarios

## Test Scenarios

### Scenario 1: Single User Workflow
**Goal**: Test basic form creation and signature submission

**Steps**:
1. Register as `teacher` (role: user)
2. Create a form: "Class Attendance"
3. Signature on the form
4. Verify form status changes to "signed"

**Expected Result**: ✅ Form created and signed successfully

---

### Scenario 2: Multi-User Approval Flow (Like Your School Principal Use Case)
**Goal**: Test the principal approval workflow

**Actor 1**: Teacher/Admin
1. Register as `admin_teacher` (role: user)
2. Create form:
   - Title: "Leave Approval Request"
   - Content: "Student John Doe requests 3-day leave for medical reasons"
3. Share form with principal (copy link or form ID)

**Actor 2**: Principal
1. Register as `principal_sharma` (role: principal)
2. Open the form shared by teacher
3. Review the document
4. Draw signature
5. Submit signature

**Expected Result**: 
- ✅ Form shows as "signed"
- ✅ Both users can see the form
- ✅ Principal's signature is stored

---

### Scenario 3: Multiple Signatures on One Form
**Goal**: Test collecting multiple signatures

**Setup**: 3 users required
1. **Admin** creates form (as user 1)
2. **Principal 1** signs it (as user 2)
3. **Principal 2** also signs it (as user 3)

**Expected Result**: 
- Form has 2 signatures
- Both signatures stored in database
- Form status: "signed"

---

### Scenario 4: Error Handling
**Goal**: Test error scenarios

Test cases:

| Test Case | Action | Expected Result |
|-----------|--------|-----------------|
| No signature drawn | Click submit without drawing | Error: "Please draw your signature first" |
| Missing form title | Try to create form without title | Error: "Please fill in all required fields" |
| Duplicate username | Register with same username twice | Error: "Username already exists" |
| Wrong password | Login with wrong password | Error: "Invalid username or password" |
| Invalid email | Try to register with invalid email | Error displayed |

---

## 🔍 Manual Testing Checklist

### Authentication ✅
- [ ] Can register new user
- [ ] Can login with valid credentials
- [ ] Cannot login with wrong password
- [ ] Duplicate usernames are prevented
- [ ] All 3 roles (user, principal, admin) can be selected

### Form Management ✅
- [ ] Can create new form
- [ ] Form appears in list
- [ ] Can view form details
- [ ] Form title and content display correctly
- [ ] Form status shows correctly (pending/signed)
- [ ] Can open any form from the list

### Signature Capture ✅
- [ ] Canvas is responsive and visible
- [ ] Can draw on canvas with mouse
- [ ] Can draw on canvas with touch (tablet)
- [ ] Clear button clears the canvas
- [ ] Cannot submit without drawing
- [ ] Signature is saved after submission

### Database ✅
- [ ] Data persists after logout/login
- [ ] Multiple users can sign same form
- [ ] Signatures are stored correctly
- [ ] Created timestamps are accurate

---

## 🛠️ API Testing (Using curl or Postman)

### Test 1: Health Check
```bash
curl http://localhost:5000/api/health
```
Expected: `{"status": "API is running"}`

### Test 2: Register User
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "role": "user"
  }'
```
Expected: User created successfully

### Test 3: Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```
Expected: Login successful with user data

### Test 4: Create Form
```bash
curl -X POST http://localhost:5000/api/forms \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Form",
    "description": "Testing form creation",
    "content": "This is test content",
    "creator_id": 1
  }'
```
Expected: Form created with ID

### Test 5: Get All Forms
```bash
curl http://localhost:5000/api/forms
```
Expected: List of all forms in JSON

### Test 6: Get Specific Form
```bash
curl http://localhost:5000/api/forms/1
```
Expected: Single form details with signatures

---

## 📊 Database Testing

### Connect to Database
```bash
docker exec -it signature_db mysql -u signature_user -psignature_pass signature_db
```

### Check Users
```sql
SELECT id, username, email, role, created_at FROM users;
```

### Check Forms
```sql
SELECT id, title, status, creator_id, created_at FROM forms;
```

### Check Signatures
```sql
SELECT id, form_id, signer_id, signed_at FROM signatures;
```

### View Full Signature Data
```sql
SELECT id, form_id, signer_id, LENGTH(signature_data) as data_size, signed_at 
FROM signatures;
```

### Check User Relationships
```sql
SELECT f.id, f.title, u.username, f.status 
FROM forms f 
LEFT JOIN users u ON f.creator_id = u.id 
ORDER BY f.created_at DESC;
```

---

## 🎯 Performance Testing

### Load 100 Forms
```python
import requests
import time

API_URL = "http://localhost:5000/api"
start = time.time()

for i in range(100):
    requests.post(f"{API_URL}/forms", json={
        "title": f"Form {i}",
        "description": f"Description {i}",
        "content": f"Content {i}",
        "creator_id": 1
    })

print(f"Created 100 forms in {time.time() - start:.2f} seconds")
```

### Get Forms Response Time
```python
import requests
import time

start = time.time()
response = requests.get("http://localhost:5000/api/forms")
elapsed = time.time() - start

print(f"Response time: {elapsed:.3f}s")
print(f"Forms count: {len(response.json())}")
```

---

## 🐛 Debugging Tips

### Check Backend Logs
- Look for errors in Flask terminal
- Common issues:
  - Database connection errors
  - JSON parsing errors
  - Missing fields in request

### Check Frontend Logs
- Open browser DevTools (F12)
- Go to Console tab
- Look for errors in red
- Common issues:
  - API URL incorrect
  - CORS errors
  - State management issues

### Check Database
```bash
# View all tables
docker exec -it signature_db mysql -u signature_user -psignature_pass signature_db -e "SHOW TABLES;"

# View table structure
docker exec -it signature_db mysql -u signature_user -psignature_pass signature_db -e "DESCRIBE users;"
```

---

## ✅ Final Verification Checklist

Before considering the app ready:

- [ ] User registration works with all roles
- [ ] Login works and persists session
- [ ] Can create forms with all fields
- [ ] Forms appear in list
- [ ] Can navigate to form
- [ ] Signature canvas draws smoothly
- [ ] Can submit signature
- [ ] Form status updates
- [ ] Multiple users can sign same form
- [ ] Data persists after logout/login
- [ ] No console errors in browser
- [ ] No SQL errors in database
- [ ] API responds within 1 second
- [ ] Can handle concurrent users

---

**All checks passed?** 🎉 Your application is ready for use!
