import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import api from '../services/api';

export default function BookingsPage() {
  const [bookings, setBookings] = useState([]);
  const [filter, setFilter] = useState('all');

  const fetchBookings = async () => {
    const res = await api.get('/bookings');
    setBookings(res.data);
  };

  useEffect(() => { fetchBookings(); }, []);

  const updateStatus = async (id, status) => {
    await api.patch(`/bookings/${id}/status`, { status });
    fetchBookings();
  };

  const filtered = filter === 'all' ? bookings : bookings.filter((b) => b.status === filter);

  return (
    <Layout>
      <h1 style={{ marginBottom: 6 }}>Bookings</h1>
      <p style={{ color: 'var(--color-grey)', marginBottom: 24 }}>All rider bookings across tours</p>

      <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
        {['all', 'pending', 'confirmed', 'completed', 'cancelled'].map((s) => (
          <button
            key={s}
            onClick={() => setFilter(s)}
            style={{
              background: filter === s ? 'var(--color-yellow)' : 'transparent',
              color: filter === s ? 'var(--color-black)' : 'var(--color-white)',
              border: '1px solid var(--color-yellow)',
              borderRadius: 20,
              padding: '7px 16px',
              fontSize: 12,
              fontWeight: 600,
              textTransform: 'capitalize',
            }}
          >
            {s}
          </button>
        ))}
      </div>

      <div style={{ background: 'var(--color-black-light)', borderRadius: 14, border: '1px solid var(--color-border)', overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid var(--color-border)' }}>
              {['Rider', 'Route', 'Pickup', 'Seats', 'Fare', 'Status', 'Actions'].map((h) => (
                <th key={h} style={{ textAlign: 'left', padding: '14px 16px', fontSize: 12, color: 'var(--color-grey)' }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((booking) => (
              <tr key={booking.id}>
                <td style={cellStyle}>{booking.User?.fullName || '—'}</td>
                <td style={cellStyle}>{booking.routeName || '—'}</td>
                <td style={cellStyle}>{booking.pickupStop || '—'}</td>
                <td style={cellStyle}>{booking.seatCount}</td>
                <td style={cellStyle}>{booking.currency || 'UGX'} {booking.totalFare}</td>
                <td style={cellStyle}>
                  <span style={{ color: statusColor(booking.status), fontWeight: 600, textTransform: 'capitalize' }}>
                    {booking.status}
                  </span>
                </td>
                <td style={cellStyle}>
                  <select
                    value={booking.status}
                    onChange={(e) => updateStatus(booking.id, e.target.value)}
                    style={{ background: '#0d0d0d', color: 'white', border: '1px solid var(--color-border)', borderRadius: 6, padding: '4px 8px', fontSize: 12 }}
                  >
                    <option value="pending">Pending</option>
                    <option value="confirmed">Confirmed</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p style={{ padding: 20, color: 'var(--color-grey)' }}>No bookings found.</p>}
      </div>
    </Layout>
  );
}

function statusColor(status) {
  if (status === 'confirmed' || status === 'completed') return 'var(--color-yellow)';
  if (status === 'cancelled') return 'var(--color-red)';
  return 'var(--color-grey)';
}

const cellStyle = { padding: '14px 16px', fontSize: 13 };