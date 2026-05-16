import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import axios from 'axios';
import LoginPage from './components/LoginPage';
import RegisterPage from './components/RegisterPage';
import FormPage from './components/FormPage';
import SignaturePage from './components/SignaturePage';
import './App.css';

function App() {
  const [user, setUser] = useState(null);
  const API_BASE_URL = 'http://localhost:5000/api';

  const handleLogin = (userData) => {
    setUser(userData);
  };

  const handleLogout = () => {
    setUser(null);
  };

  return (
    <Router>
      <div className="App">
        <nav className="navbar">
          <div className="nav-container">
            <h1 className="logo">📝 Signature App</h1>
            {user && (
              <div className="nav-user">
                <span>Hello, {user.username}!</span>
                <button onClick={handleLogout} className="logout-btn">Logout</button>
              </div>
            )}
          </div>
        </nav>

        <Routes>
          {!user ? (
            <>
              <Route path="/" element={<Navigate to="/login" />} />
              <Route path="/login" element={<LoginPage onLogin={handleLogin} API_BASE_URL={API_BASE_URL} />} />
              <Route path="/register" element={<RegisterPage API_BASE_URL={API_BASE_URL} />} />
            </>
          ) : (
            <>
              <Route path="/" element={<FormPage user={user} API_BASE_URL={API_BASE_URL} />} />
              <Route path="/form/:formId" element={<SignaturePage user={user} API_BASE_URL={API_BASE_URL} />} />
              <Route path="*" element={<Navigate to="/" />} />
            </>
          )}
          <Route path="*" element={!user ? <Navigate to="/login" /> : <Navigate to="/" />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
