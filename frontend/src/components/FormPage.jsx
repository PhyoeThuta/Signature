import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

function FormPage({ user, API_BASE_URL }) {
  const [forms, setForms] = useState([]);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newForm, setNewForm] = useState({
    title: '',
    description: '',
    content: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchForms();
  }, []);

  const fetchForms = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/forms`);
      setForms(response.data);
    } catch (err) {
      setError('Failed to load forms');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateForm = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!newForm.title || !newForm.content) {
      setError('Please fill in all required fields');
      return;
    }

    try {
      setLoading(true);
      const response = await axios.post(`${API_BASE_URL}/forms`, {
        ...newForm,
        creator_id: user.user_id
      });

      setSuccess('Form created successfully!');
      setNewForm({ title: '', description: '', content: '' });
      setShowCreateForm(false);
      fetchForms();
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to create form');
    } finally {
      setLoading(false);
    }
  };

  const handleFormClick = (formId) => {
    navigate(`/form/${formId}`);
  };

  return (
    <div className="container">
      <div style={{ marginBottom: '2rem' }}>
        <h1 style={{ color: 'white', marginBottom: '1rem' }}>Forms Dashboard</h1>
        <button
          onClick={() => setShowCreateForm(!showCreateForm)}
          className="btn"
          style={{ marginBottom: '1rem' }}
        >
          {showCreateForm ? '✕ Cancel' : '+ Create New Form'}
        </button>
      </div>

      {error && <div className="message error">{error}</div>}
      {success && <div className="message success">{success}</div>}

      {showCreateForm && (
        <div className="form-container" style={{ marginBottom: '2rem' }}>
          <h2>Create New Form</h2>
          <form onSubmit={handleCreateForm}>
            <div className="form-group">
              <label>Form Title *</label>
              <input
                type="text"
                value={newForm.title}
                onChange={(e) => setNewForm({ ...newForm, title: e.target.value })}
                placeholder="e.g., Principal Approval Document"
                required
              />
            </div>
            <div className="form-group">
              <label>Description</label>
              <textarea
                value={newForm.description}
                onChange={(e) => setNewForm({ ...newForm, description: e.target.value })}
                placeholder="Brief description of the form"
              />
            </div>
            <div className="form-group">
              <label>Form Content *</label>
              <textarea
                value={newForm.content}
                onChange={(e) => setNewForm({ ...newForm, content: e.target.value })}
                placeholder="Enter the form details or content"
                required
                style={{ minHeight: '150px' }}
              />
            </div>
            <button type="submit" className="btn" disabled={loading}>
              {loading ? 'Creating...' : 'Create Form'}
            </button>
          </form>
        </div>
      )}

      <div>
        <h2 style={{ color: 'white', marginBottom: '1.5rem' }}>Available Forms</h2>
        {loading && !forms.length ? (
          <div className="loader"></div>
        ) : forms.length === 0 ? (
          <div className="form-container">
            <p style={{ textAlign: 'center', color: '#999' }}>No forms available yet. Create one to get started!</p>
          </div>
        ) : (
          <div className="forms-list">
            {forms.map((form) => (
              <div
                key={form.id}
                className="form-card"
                onClick={() => handleFormClick(form.id)}
              >
                <h3>{form.title}</h3>
                <p>{form.description || 'No description provided'}</p>
                <div style={{ fontSize: '0.9rem', color: '#999', marginBottom: '0.5rem' }}>
                  Created: {new Date(form.created_at).toLocaleDateString()}
                </div>
                <span className={`status-badge status-${form.status}`}>
                  {form.status === 'pending' ? '⏳ Pending' : '✓ Signed'}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default FormPage;
