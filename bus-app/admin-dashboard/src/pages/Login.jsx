import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, password);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Login failed.');
    } finally {
      setLoading(false);
    }
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  return (
    <div style={styles.wrapper}>
      <form style={styles.card} onSubmit={handleSubmit}>
        <div style={styles.iconCircle}>B</div>
        <h1 style={styles.title}>Admin Login</h1>
        <p style={styles.subtitle}>Sign in to manage tours, buses, and bookings</p>

        {error && <div style={styles.error}>{error}</div>}

        <label style={styles.label}>Email</label>
        <input
          style={styles.input}
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />

        <label style={styles.label}>Password</label>
        <div style={styles.passwordWrapper}>
          <input
            style={styles.passwordInput}
            type={showPassword ? 'text' : 'password'}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <button
            type="button"
            style={styles.toggleButton}
            onClick={togglePasswordVisibility}
            aria-label={showPassword ? 'Hide password' : 'Show password'}
          >
            {showPassword ? (
              // Eye-off icon (hidden)
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                <line x1="1" y1="1" x2="23" y2="23" />
              </svg>
            ) : (
              // Eye icon (visible)
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                <circle cx="12" cy="12" r="3" />
              </svg>
            )}
          </button>
        </div>

        <button style={styles.button} type="submit" disabled={loading}>
          {loading ? 'Signing in...' : 'Sign In'}
        </button>
      </form>
    </div>
  );
}

const styles = {
  wrapper: {
    height: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'var(--color-black)',
  },
  card: {
    width: 380,
    padding: '40px 32px',
    background: 'var(--color-black-light)',
    borderRadius: 16,
    border: '1px solid var(--color-border)',
    display: 'flex',
    flexDirection: 'column',
  },
  iconCircle: {
    width: 48,
    height: 48,
    borderRadius: 12,
    background: 'var(--color-yellow)',
    color: 'var(--color-black)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 'bold',
    fontSize: 22,
    marginBottom: 20,
  },
  title: { fontSize: 22, marginBottom: 6 },
  subtitle: { color: 'var(--color-grey)', fontSize: 13, marginBottom: 24 },
  label: { fontSize: 12, color: 'var(--color-grey)', marginBottom: 6, marginTop: 14 },
  input: {
    background: '#0d0d0d',
    border: '1px solid var(--color-border)',
    borderRadius: 10,
    padding: '12px 14px',
    color: 'var(--color-white)',
    fontSize: 14,
    outline: 'none',
  },
  passwordWrapper: {
    display: 'flex',
    alignItems: 'center',
    background: '#0d0d0d',
    border: '1px solid var(--color-border)',
    borderRadius: 10,
    position: 'relative',
  },
  passwordInput: {
    flex: 1,
    background: 'transparent',
    border: 'none',
    padding: '12px 14px',
    color: 'var(--color-white)',
    fontSize: 14,
    outline: 'none',
  },
  toggleButton: {
    background: 'transparent',
    border: 'none',
    color: 'var(--color-grey)',
    cursor: 'pointer',
    padding: '8px 14px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    transition: 'color 0.2s',
  },
  button: {
    marginTop: 28,
    background: 'var(--color-yellow)',
    color: 'var(--color-black)',
    border: 'none',
    borderRadius: 10,
    padding: '13px',
    fontWeight: 'bold',
    fontSize: 15,
    cursor: 'pointer',
  },
  error: {
    background: 'rgba(229, 57, 53, 0.15)',
    border: '1px solid var(--color-red)',
    color: 'var(--color-red)',
    padding: '10px 14px',
    borderRadius: 8,
    fontSize: 13,
    marginBottom: 6,
  },
};