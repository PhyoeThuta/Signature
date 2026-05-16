import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';

function SignaturePage({ user, API_BASE_URL }) {
  const { formId } = useParams();
  const navigate = useNavigate();
  const canvasRef = useRef(null);
  const [form, setForm] = useState(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchForm();
    initializeCanvas();
  }, [formId]);

  useEffect(() => {
    window.addEventListener('resize', resizeCanvas);
    return () => window.removeEventListener('resize', resizeCanvas);
  }, []);

  const fetchForm = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/forms/${formId}`);
      setForm(response.data);
    } catch (err) {
      setError('Failed to load form');
    }
  };

  const initializeCanvas = () => {
    setTimeout(() => {
      const canvas = canvasRef.current;
      if (canvas) {
        resizeCanvas();
      }
    }, 100);
  };

  const resizeCanvas = () => {
    const canvas = canvasRef.current;
    if (canvas) {
      const container = canvas.parentElement;
      canvas.width = container.offsetWidth;
      canvas.height = 300;
      drawBorder();
    }
  };

  const drawBorder = () => {
    const canvas = canvasRef.current;
    if (canvas) {
      const ctx = canvas.getContext('2d');
      ctx.strokeStyle = '#ddd';
      ctx.lineWidth = 1;
      ctx.strokeRect(0, 0, canvas.width, canvas.height);
    }
  };

  const startDrawing = (e) => {
    setIsDrawing(true);
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left || e.touches[0].clientX - rect.left;
    const y = e.clientY - rect.top || e.touches[0].clientY - rect.top;

    ctx.beginPath();
    ctx.moveTo(x, y);
  };

  const draw = (e) => {
    if (!isDrawing) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left || e.touches[0].clientX - rect.left;
    const y = e.clientY - rect.top || e.touches[0].clientY - rect.top;

    ctx.lineTo(x, y);
    ctx.strokeStyle = '#333';
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();
  };

  const stopDrawing = () => {
    setIsDrawing(false);
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawBorder();
  };

  const submitSignature = async () => {
    const canvas = canvasRef.current;
    const signatureData = canvas.toDataURL('image/png');

    if (signatureData === 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==') {
      setError('Please draw your signature first');
      return;
    }

    try {
      setLoading(true);
      setError('');
      
      await axios.post(`${API_BASE_URL}/signatures`, {
        form_id: parseInt(formId),
        signer_id: user.user_id,
        signature_data: signatureData
      });

      setSuccess('Signature submitted successfully!');
      setTimeout(() => {
        navigate('/');
      }, 2000);
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to submit signature');
    } finally {
      setLoading(false);
    }
  };

  if (!form) {
    return <div className="container"><div className="loader"></div></div>;
  }

  return (
    <div className="container">
      <button
        onClick={() => navigate('/')}
        className="btn"
        style={{ marginBottom: '1rem', backgroundColor: '#95a5a6' }}
      >
        ← Back to Forms
      </button>

      <div className="form-container">
        <h2>{form.title}</h2>
        {form.description && <p style={{ color: '#666', marginBottom: '1rem' }}>{form.description}</p>}

        <div style={{ marginBottom: '2rem', padding: '1rem', backgroundColor: '#f9f9f9', borderRadius: '4px' }}>
          <h3>Form Content:</h3>
          <p style={{ whiteSpace: 'pre-wrap', color: '#555' }}>{form.content}</p>
        </div>

        {error && <div className="message error">{error}</div>}
        {success && <div className="message success">{success}</div>}

        <div style={{ marginBottom: '1.5rem' }}>
          <h3>Your Signature</h3>
          <p style={{ color: '#666', fontSize: '0.9rem', marginBottom: '0.5rem' }}>
            Please sign below to approve this form:
          </p>
          <div className="signature-canvas-container">
            <canvas
              ref={canvasRef}
              className="signature-canvas"
              onMouseDown={startDrawing}
              onMouseMove={draw}
              onMouseUp={stopDrawing}
              onMouseLeave={stopDrawing}
              onTouchStart={startDrawing}
              onTouchMove={draw}
              onTouchEnd={stopDrawing}
            />
          </div>
        </div>

        <div className="canvas-buttons">
          <button
            onClick={clearCanvas}
            className="btn btn-clear"
            type="button"
          >
            🗑 Clear Signature
          </button>
          <button
            onClick={submitSignature}
            className="btn btn-submit"
            disabled={loading}
            type="button"
          >
            {loading ? '⏳ Submitting...' : '✓ Submit Signature'}
          </button>
        </div>

        {form.signatures && form.signatures.length > 0 && (
          <div style={{ marginTop: '2rem', padding: '1rem', backgroundColor: '#f0f0f0', borderRadius: '4px' }}>
            <h3>Signatures Collected:</h3>
            <p>{form.signatures.length} signature(s) received</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default SignaturePage;
