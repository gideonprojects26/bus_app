import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const links = [
  { to: '/', label: 'Dashboard', icon: '⬛' },
  { to: '/routes', label: 'Tour Routes', icon: '🚌' },
  { to: '/buses', label: 'Buses', icon: '🚍' },
  { to: '/drivers', label: 'Drivers', icon: '🧑' },
  { to: '/bookings', label: 'Bookings', icon: '📋' },
  { to: '/rentals', label: 'Rental Requests', icon: '📨' },
];

export default function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div style={styles.sidebar}>
      <div>
        <div style={styles.logo}>
          <div style={styles.logoIcon}>B</div>
          <span style={styles.logoText}>Bus Admin</span>
        </div>

        <nav style={styles.nav}>
          {links.map((link) => (
            <NavLink
              key={link.to}
              to={link.to}
              end={link.to === '/'}
              style={({ isActive }) => ({
                ...styles.navItem,
                background: isActive ? 'rgba(255,193,7,0.12)' : 'transparent',
                color: isActive ? 'var(--color-yellow)' : 'var(--color-white)',
                borderLeft: isActive ? '3px solid var(--color-yellow)' : '3px solid transparent',
              })}
            >
              <span style={{ marginRight: 10 }}>{link.icon}</span>
              {link.label}
            </NavLink>
          ))}
        </nav>
      </div>

      <div style={styles.footer}>
        <div style={styles.userBox}>
          <div style={styles.avatar}>{user?.fullName?.charAt(0) || 'A'}</div>
          <div>
            <div style={styles.userName}>{user?.fullName || 'Admin'}</div>
            <div style={styles.userEmail}>{user?.email}</div>
          </div>
        </div>
        <button style={styles.logoutBtn} onClick={handleLogout}>
          Logout
        </button>
      </div>
    </div>
  );
}

const styles = {
  sidebar: {
    width: 240,
    height: '100vh',
    background: 'var(--color-black-light)',
    borderRight: '1px solid var(--color-border)',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    position: 'fixed',
    left: 0,
    top: 0,
  },
  logo: {
    display: 'flex',
    alignItems: 'center',
    padding: '22px 20px',
    borderBottom: '1px solid var(--color-border)',
  },
  logoIcon: {
    width: 32,
    height: 32,
    borderRadius: 8,
    background: 'var(--color-yellow)',
    color: 'var(--color-black)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 'bold',
    marginRight: 10,
  },
  logoText: { fontWeight: 'bold', fontSize: 16 },
  nav: { display: 'flex', flexDirection: 'column', padding: '16px 0' },
  navItem: {
    display: 'flex',
    alignItems: 'center',
    padding: '13px 20px',
    textDecoration: 'none',
    fontSize: 14,
    transition: 'background 0.15s',
  },
  footer: {
    padding: 20,
    borderTop: '1px solid var(--color-border)',
  },
  userBox: { display: 'flex', alignItems: 'center', marginBottom: 14 },
  avatar: {
    width: 34,
    height: 34,
    borderRadius: '50%',
    background: 'var(--color-yellow)',
    color: 'var(--color-black)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 'bold',
    marginRight: 10,
  },
  userName: { fontSize: 13, fontWeight: 600 },
  userEmail: { fontSize: 11, color: 'var(--color-grey)' },
  logoutBtn: {
    width: '100%',
    background: 'transparent',
    border: '1px solid var(--color-red)',
    color: 'var(--color-red)',
    borderRadius: 8,
    padding: '9px',
    fontSize: 13,
  },
};