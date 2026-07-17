import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import api from '../services/api';

export default function RentalRequestsPage() {
  const [rentals, setRentals] = useState([]);
  const [filter, setFilter] = useState('all');

  const fetchRentals = async () => {
    const res = await api.get('/rentals');
    setRentals(res.data);
  };

  useEffect(() => { fetchRentals(); }, []);

  const updateStatus = async (id, status) => {
    await api.patch(`/rentals/${id}/status`, { status });
    fetchRentals();
  };

  const filtered = filter === 'all' ? rentals : rentals.filter((r) => r.status === filter);

  return (
    <Layout>
      <h1 style={{ marginBottom: 6 }}>Rental Requests</h1>
      <p style={{ color: 'var(--color-grey)', marginBottom: 24 }}>Bus rental inquiries submitted from the app</p>

      <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
        {['all', 'pending', 'contacted', 'confirmed', 'declined'].map((s) => (
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

      <div style={{ display: 'grid', gap: 16 }}>
        {filtered.map((rental) => (
          <div
            key={rental.id}
            style={{
              background: 'var(--color-black-light)',
              border: '1px solid var(--color-border)',
              borderRadius: 14,
              padding: 20,
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <h3 style={{ marginBottom: 6 }}>{rental.fullName}</h3>
                <p style={{ fontSize: 13, color: 'var(--color-grey)' }}>{rental.phone}</p>
                <p style={{ fontSize: 13, marginTop: 6 }}>
                  {rental.passengerCount} passengers &middot; Needed on {rental.neededDate}
                </p>
                {rental.additionalDetails && (
                  <p style={{ fontSize: 13, color: 'var(--color-grey)', marginTop: 6 }}>{rental.additionalDetails}</p>
                )}
                <p style={{ fontSize: 11, color: 'var(--color-grey)', marginTop: 10 }}>
                  Submitted {new Date(rental.createdAt).toLocaleString()}
                </p>
              </div>
              <select
                value={rental.status}
                onChange={(e) => updateStatus(rental.id, e.target.value)}
                style={{
                  background: 'var(--color-black)',
                  color: 'var(--color-white)',
                  border: '1px solid var(--color-border)',
                  borderRadius: 8,
                  padding: '6px 10px',
                  fontSize: 12,
                }}
              >
                <option value="pending">Pending</option>
                <option value="contacted">Contacted</option>
                <option value="confirmed">Confirmed</option>
                <option value="declined">Declined</option>
              </select>
            </div>
          </div>
        ))}
        {filtered.length === 0 && <p style={{ color: 'var(--color-grey)' }}>No rental requests found.</p>}
      </div>
    </Layout>
  );
}