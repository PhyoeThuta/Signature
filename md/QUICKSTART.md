# 🚀 Quick Start Guide

This guide will get you up and running in 5 minutes!

## 📋 Prerequisites Check

Before starting, make sure you have:
- ✅ Docker installed (https://www.docker.com/)
- ✅ Node.js installed (https://nodejs.org/) - v14 or higher
- ✅ Python installed (https://www.python.org/) - v3.8 or higher
- ✅ Git (optional)

## ⚡ Start in 4 Steps

### Step 1️⃣: Start the Database (30 seconds)

```bash
cd signature-app
docker-compose up -d
```

✅ MySQL is now running on port 3306

### Step 2️⃣: Start the Backend (1 minute)

Open a **NEW terminal** and run:

```bash
cd signature-app/backend

# Windows
python -m venv venv
venv\Scripts\activate

# Mac/Linux
python -m venv venv
source venv/bin/activate

# Install & Run (same for all)
python app.py
```

✅ Backend is now running on http://localhost:5000

### Step 3️⃣: Start the Frontend (2 minutes)

Open a **NEW terminal** and run:

```bash
cd signature-app/frontend
npm install
npm start
```

✅ Frontend is now running on http://localhost:3000

### Step 4️⃣: Open and Use the App

1. Open your browser: http://localhost:3000
2. **Register** a new account
   - Username: `principal` (or anything)
   - Email: `principal@school.com`
   - Password: `123456`
   - Role: Select `principal`
3. Click **Login** and use those credentials
4. **Create a Form**
   - Title: "Approval Form"
   - Content: "Please sign this document"
5. Click on the form to open it
6. **Draw your signature** on the canvas
7. Click **Submit Signature** ✓

🎉 **Done! Your signature is saved in the database!**

---

## 🔍 Verify Everything is Running

Check these URLs:

- **Frontend**: http://localhost:3000 ✅
- **Backend API**: http://localhost:5000/api/health ✅
- **Database**: Running in Docker ✅

If all show ✅, you're good to go!

---

## 📱 Test the Full Workflow

### Scenario: Principal needs to sign a form

1. **Admin creates a form** (as user 1)
   - Opens frontend
   - Creates form with document details

2. **Principal signs the form** (as user 2)
   - Registers as "principal"
   - Opens the form
   - Draws signature
   - Submits

3. **Check Database** (optional)
   ```bash
   docker exec -it signature_db mysql -u signature_user -psignature_pass signature_db
   SELECT * FROM forms;
   SELECT * FROM signatures;
   EXIT;
   ```

---

## 🛑 Stopping Everything

When done, run:

```bash
# Stop containers
docker-compose down

# Stop terminals: Press Ctrl+C in Flask and React terminals
```

---

## ⚠️ Common Issues & Fixes

### Issue: "Port 3000 already in use"
```bash
# Find and kill process
# Windows: netstat -ano | findstr :3000
# Mac/Linux: lsof -i :3000
```

### Issue: "Can't connect to MySQL"
```bash
# Check Docker is running
docker ps

# If not, start it:
docker-compose up -d
```

### Issue: "Module not found" (Python)
```bash
# Make sure virtual env is activated:
venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux
```

### Issue: React won't start
```bash
cd frontend
rm -rf node_modules
npm install
npm start
```

---

## 📚 Next: Read Full Documentation

See **README.md** for:
- Detailed API endpoints
- Database schema
- Configuration options
- Security recommendations
- Feature extensions

---

## 🎓 Learning Path

1. **Understand the flow**: User → Form → Signature → Database
2. **Explore the code**: Check `src/components/` in frontend
3. **Test the API**: Use Postman or curl to test endpoints
4. **Modify**: Try changing colors, form fields, or signature behavior
5. **Extend**: Add email notifications, PDF export, etc.

---

## 💡 Pro Tips

💡 **Tip 1**: Keep 3 terminals open (MySQL, Backend, Frontend) while developing

💡 **Tip 2**: Sign in as different users to test multi-person workflows

💡 **Tip 3**: Use browser DevTools (F12) to debug React issues

💡 **Tip 4**: Use `docker logs signature_db` to debug database issues

---

**Questions?** Check the **README.md** file for more details!

**Ready? Run Step 1 now!** 🚀
