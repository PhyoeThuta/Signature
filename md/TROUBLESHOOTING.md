# 🔧 Troubleshooting Guide

Solutions to common issues you might encounter.

## 🚀 Startup Issues

### Issue: "Docker daemon is not running"
```
Error: Cannot connect to Docker daemon
```

**Solution**:
1. Open Docker Desktop (Mac/Windows)
2. Wait for it to start (can take 1-2 minutes)
3. Verify: `docker ps`
4. Try again: `docker-compose up -d`

**For Linux**:
```bash
sudo systemctl start docker
```

---

### Issue: "Port 3306 already in use"
```
Error: Bind for 0.0.0.0:3306 failed: port is already allocated
```

**Solution 1**: Stop existing MySQL
```bash
# Windows
netstat -ano | findstr :3306
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :3306
kill -9 <PID>
```

**Solution 2**: Use different port Edit `docker-compose.yml`:
```yaml
ports:
  - "3307:3306"  # Changed from 3306
```

Then update `backend/config.py`:
```python
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://signature_user:signature_pass@localhost:3307/signature_db'
```

---

### Issue: "Port 5000 already in use"
```
Error: Address already in use
```

**Solution 1**: Kill existing process
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :5000
kill -9 <PID>
```

**Solution 2**: Use different port in `backend/app.py`:
```python
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)  # Changed port
```

---

### Issue: "Port 3000 already in use"
```
Error: Something is already listening on port 3000
```

**Solution 1**: Kill existing process
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :3000
kill -9 <PID>
```

**Solution 2**: Use different port
```bash
cd frontend
PORT=3001 npm start  # Windows/Linux
# Or edit package.json scripts
```

---

## 🐍 Backend (Flask) Issues

### Issue: "ModuleNotFoundError: No module named 'flask'"
```
Error: ModuleNotFoundError: No module named 'flask'
```

**Solution**:
1. Make sure virtual environment is activated:
   ```bash
   # Windows
   venv\Scripts\activate
   
   # Mac/Linux
   source venv/bin/activate
   ```
2. Install requirements:
   ```bash
   pip install -r requirements.txt
   ```
3. Verify installation:
   ```bash
   pip list | grep Flask
   ```

---

### Issue: "Connection refused at 127.0.0.1:3306"
```
Error: (pymysql.err.OperationalError) (2003, "Can't connect to MySQL server")
```

**Solution**:
1. Check if Docker container is running:
   ```bash
   docker ps | grep signature_db
   ```
2. If not running, start it:
   ```bash
   docker-compose up -d
   ```
3. Wait 10 seconds for MySQL to fully start
4. Check logs:
   ```bash
   docker logs signature_db
   ```

---

### Issue: "Access denied for user 'signature_user'"
```
Error: (pymysql.err.OperationalError) (1045, "Access denied for user")
```

**Solution**: Verify credentials in `backend/config.py` match `docker-compose.yml`:
```
Username: signature_user
Password: signature_pass
Database: signature_db
```

Or reset container:
```bash
docker-compose down
docker-compose up -d
```

---

### Issue: "SyntaxError in app.py"
```
Error: SyntaxError: invalid syntax at line X
```

**Solution**:
1. Check Python version:
   ```bash
   python --version  # Should be 3.8+
   ```
2. Verify file encoding (UTF-8)
3. Look for unclosed brackets or quotes
4. Run syntax check:
   ```bash
   python -m py_compile app.py
   ```

---

### Issue: "CORS error - blocked by policy"
```
Error: Access to XMLHttpRequest blocked by CORS policy
```

**Solution**: Already configured in app.py!
```python
from flask_cors import CORS
CORS(app)
```

If still having issues:
- Ensure both frontend and backend are running
- Check API_BASE_URL in frontend
- Clear browser cache

---

## 🎨 Frontend (React) Issues

### Issue: "npm ERR! code ENOENT"
```
Error: npm ERR! code ENOENT
```

**Solution**:
1. Make sure you're in `frontend/` directory:
   ```bash
   cd signature-app/frontend
   pwd  # Verify you're in frontend
   ```
2. Delete node_modules and reinstall:
   ```bash
   rm -rf node_modules
   npm install
   ```

---

### Issue: "Cannot find module 'react'"
```
Module not found: Can't resolve 'react'
```

**Solution**:
1. Ensure npm packages installed:
   ```bash
   npm install
   ```
2. Clear npm cache:
   ```bash
   npm cache clean --force
   ```
3. Reinstall:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

---

### Issue: "Unexpected token < in JSON"
```
SyntaxError: Unexpected token < in JSON at position 0
```

**Likely Cause**: API returning HTML error page instead of JSON

**Solution**:
1. Check if backend is running:
   ```bash
   curl http://localhost:5000/api/health
   ```
2. If error, check backend terminal for errors
3. Check browser console (F12) for actual error message

---

### Issue: "app.jsx not found"
```
Error: Module not found: Can't resolve './App.jsx'
```

**Solution**: React files should end in `.jsx`, not `.js`:
```bash
# Check file exists
ls src/App.jsx

# If it's App.js, rename it
mv src/App.js src/App.jsx
```

---

### Issue: "TypeError: Cannot read property of undefined"
```
Uncaught TypeError: Cannot read property 'user_id' of undefined
```

**Solution**:
1. Open browser DevTools (F12)
2. Look for line number and check that code
3. Verify state is initialized properly
4. Check user object structure from login API

---

### Issue: "Signature canvas not visible"
```
Canvas appears but won't draw
```

**Solution**:
1. Check canvas width/height are set
2. Verify touch/mouse event listeners
3. Clear browser cache
4. Try different browser
5. Check browser console for errors

---

## 🗄️ Database Issues

### Issue: "Table doesn't exist"
```
Error: (pymysql.err.ProgrammingError) (1146, "Table 'signature_db.users' doesn't exist")
```

**Solution**: Tables are auto-created, but may have failed:
```bash
# Restart Flask to recreate tables
# In backend directory, stop and run:
python app.py

# Check database directly:
docker exec -it signature_db mysql -u signature_user -psignature_pass signature_db
SHOW TABLES;
```

---

### Issue: "Database locked"
```
Error: database is locked
```

**Solution**: Restart database container
```bash
docker-compose down
docker-compose up -d
```

---

### Issue: "Data not persisting"
```
Data saved but disappeared after restart
```

**Likely Cause**: MySQL not configured with volume persistence

**Solution**: Already fixed in `docker-compose.yml` with volumes:
```yaml
volumes:
  - mysql_data:/var/lib/mysql
```

If experiencing issue:
```bash
docker volume ls | grep mysql_data
docker volume inspect mysql_data

# If still issues, backup and restart
docker-compose down -v  # Warning: deletes data!
docker-compose up -d
```

---

## 🔍 Debugging Tips

### Enable Debug Mode

**Backend** - Already enabled in app.py:
```python
app.run(debug=True)  # Auto-reloads on file changes
```

**Frontend** - Use React DevTools:
1. Install React DevTools extension
2. Open Chrome DevTools (F12)
3. Go to React tab

### Check All Services

```bash
# Terminal 1: Check MySQL
docker ps
docker logs signature_db

# Terminal 2: Check Flask output
cd backend
python app.py
# Look for: "Running on http://127.0.0.1:5000"

# Terminal 3: Check React output
cd frontend
npm start
# Look for: "On Your Network"
```

### Test Each Component

```bash
# Test Database
docker exec -it signature_db mysql -u signature_user -psignature_pass signature_db -e "SHOW TABLES;"

# Test Backend API
curl http://localhost:5000/api/health

# Test Frontend loads
curl http://localhost:3000
```

---

## 📋 Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | Service not running | Start the service |
| `Port in use` | Another process on port | Kill process or change port |
| `Module not found` | Dependencies not installed | Run `npm install` or `pip install -r requirements.txt` |
| `CORS error` | Frontend/Backend mismatch | Check URLs and CORS config |
| `404 Not Found` | Wrong endpoint | Check API endpoint spelling |
| `401 Unauthorized` | Wrong credentials | Verify username/password |
| `500 Server Error` | Backend error | Check Flask terminal log|
| `Database locked` | Connection issue | Restart Docker |

---

## 🆘 Last Resort: Complete Reset

If everything is broken:

```bash
# Stop all services
docker-compose down

# Remove all data (WARNING: deletes database)
docker-compose down -v

# Clean up Python cache
cd backend
rm -rf __pycache__
rm -rf venv

# Clean up npm cache
cd ../frontend
rm -rf node_modules
rm package-lock.json

# Start fresh
cd ..
docker-compose up -d

# Then follow QUICKSTART.md from beginning
```

---

## 📞 Getting Help

1. **Check logs first**:
   ```bash
   # Flask backend
   # Look at terminal output from: python app.py
   
   # React frontend
   # Look at terminal output from: npm start
   
   # Docker database
   docker logs signature_db
   ```

2. **Browser DevTools (F12)**:
   - Console: JavaScript errors
   - Network: API request/response
   - Application: Storage/Cookies

3. **Check documentation**:
   - API_DOCUMENTATION.md - API endpoint reference
   - README.md - Architecture and setup
   - TESTING.md - Expected behavior

4. **Common fixes**:
   - Refresh browser (Ctrl+F5 or Cmd+Shift+R)
   - Clear browser cache
   - Restart services
   - Check all services running on correct ports

---

**Still stuck?** Try running the health check endpoint:
```bash
curl http://localhost:5000/api/health
```

If this works, backend is OK. Then test frontend by visiting:
```
http://localhost:3000
```

Both working? Check browser console (F12) for specific errors!

---

**Version**: 1.0.0  
**Last Updated**: March 2024
