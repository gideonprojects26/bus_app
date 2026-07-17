import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import api from '../services/api';

export default function Dashboard() {
  const [stats, setStats] = useState({ routes: 0, buses: 0, drivers: 0, bookings: 0 });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [routesRes, busesRes, driversRes, bookingsRes] = await Promise.all([
          api.get('/routes'),
          api.get('/buses'),
          api.get('/drivers'),
          api.get('/bookings'),
        ]);
        setStats({
          routes: routesRes.data.length,
          buses: busesRes.data.length,
          drivers: driversRes.data.length,
          bookings: bookingsRes.data.length,
        });
      } catch (err) {
        console.error('Failed to load stats', err);
      }
    };
    fetchStats();
  }, []);

  const cards = [
    { label: 'Tour Routes', value: stats.routes, color: 'var(--color-yellow)' },
    { label: 'Buses', value: stats.buses, color: 'var(--color-red)' },
    { label: 'Drivers', value: stats.drivers, color: 'var(--color-yellow)' },
    { label: 'Total Bookings', value: stats.bookings, color: 'var(--color-red)' },
  ];

  return (
    <Layout>
      <h1 style={{ marginBottom: 6 }}>Dashboard</h1>
      <p style={{ color: 'var(--color-grey)', marginBottom: 28 }}>Overview of your bus tour operations</p>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 20 }}>
        {cards.map((card) => (
          <div
            key={card.label}
            style={{
              background: 'var(--color-black-light)',
              border: '1px solid var(--color-border)',
              borderRadius: 14,
              padding: 22,
            }}
          >
            <div style={{ color: 'var(--color-grey)', fontSize: 13, marginBottom: 8 }}>{card.label}</div>
            <div style={{ fontSize: 30, fontWeight: 'bold', color: card.color }}>{card.value}</div>
          </div>
        ))}
      </div>
    </Layout>
  );
}