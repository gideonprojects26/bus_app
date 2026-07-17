import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import Modal from '../components/Modal';
import api from '../services/api';

const emptyForm = { plateNumber: '', capacity: '', routeId: '', driverId: '', status: 'idle' };

export default function BusesPage() {
  const [buses, setBuses] = useState([]);
  const [routes, setRoutes] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(emptyForm);

  const fetchAll = async () => {
    const [busesRes, routesRes, driversRes] = await Promise.all([
      api.get('/buses'),
      api.get('/routes'),
      api.get('/drivers'),
    ]);
    setBuses(busesRes.data);
    setRoutes(routesRes.data);
    setDrivers(driversRes.data);
  };

  useEffect(() => { fetchAll(); }, []);

  const openCreate = () => {
    setForm(emptyForm);
    setEditingId(null);
    setShowModal(true);
  };

  const openEdit = (bus) => {
    setForm({
      plateNumber: bus.plateNumber,
      capacity: bus.capacity,
      routeId: bus.routeId || '',
      driverId: bus.driverId || '',
      status: bus.status,
    });
    setEditingId(bus.id);
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this bus?')) return;
    await api.delete(`/buses/${id}`);
    fetchAll();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const payload = { ...form, capacity: parseInt(form.capacity) };
    if (editingId) {
      await api.put(`/buses/${editingId}`, payload);
    } else {
      await api.post('/buses', payload);
    }
    setShowModal(false);
    fetchAll();
  };

  return (
    <Layout>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 28 }}>
        <div>
          <h1 style={{ marginBottom: 6 }}>Buses</h1>
          <p style={{ color: 'var(--color-grey)' }}>Manage your fleet</p>
        </div>
        <button style={buttonStyle} onClick={openCreate}>+ New Bus</button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
        {buses.map((bus) => (
          <div key={bus.id} style={cardStyle}>
            <h3>{bus.plateNumber}</h3>
            <p style={{ fontSize: 13, color: 'var(--color-grey)', marginTop: 6 }}>Capacity: {bus.capacity}</p>
            <p style={{ fontSize: 13, color: 'var(--color-grey)' }}>Status: <span style={{ color: statusColor(bus.status) }}>{bus.status}</span></p>
            <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
              <button style={editBtn} onClick={() => openEdit(bus)}>Edit</button>
              <button style={deleteBtn} onClick={() => handleDelete(bus.id)}>Delete</button>
            </div>
          </div>
        ))}
        {buses.length === 0 && <p style={{ color: 'var(--color-grey)' }}>No buses yet.</p>}
      </div>

      {showModal && (
        <Modal title={editingId ? 'Edit Bus' : 'New Bus'} onClose={() => setShowModal(false)}>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <input style={inputStyle} placeholder="Plate Number" value={form.plateNumber}
              onChange={(e) => setForm({ ...form, plateNumber: e.target.value })} required />
            <input style={inputStyle} placeholder="Capacity" type="number" value={form.capacity}
              onChange={(e) => setForm({ ...form, capacity: e.target.value })} required />
            <select style={inputStyle} value={form.routeId} onChange={(e) => setForm({ ...form, routeId: e.target.value })}>
              <option value="">Assign a route (optional)</option>
              {routes.map((r) => <option key={r.id} value={r.id}>{r.name}</option>)}
            </select>
            <select style={inputStyle} value={form.driverId} onChange={(e) => setForm({ ...form, driverId: e.target.value })}>
              <option value="">Assign a driver (optional)</option>
              {drivers.map((d) => <option key={d.id} value={d.id}>{d.fullName}</option>)}
            </select>
            <select style={inputStyle} value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value })}>
              <option value="idle">Idle</option>
              <option value="on_route">On Route</option>
              <option value="maintenance">Maintenance</option>
            </select>
            <button style={buttonStyle} type="submit">{editingId ? 'Update Bus' : 'Create Bus'}</button>
          </form>
        </Modal>
      )}
    </Layout>
  );
}

function statusColor(status) {
  if (status === 'on_route') return 'var(--color-yellow)';
  if (status === 'maintenance') return 'var(--color-red)';
  return 'var(--color-grey)';
}

const buttonStyle = { background: 'var(--color-yellow)', color: 'var(--color-black)', border: 'none', borderRadius: 10, padding: '11px 20px', fontWeight: 'bold', fontSize: 14 };
const cardStyle = { background: 'var(--color-black-light)', border: '1px solid var(--color-border)', borderRadius: 14, padding: 18 };
const editBtn = { background: 'transparent', border: '1px solid var(--color-yellow)', color: 'var(--color-yellow)', borderRadius: 8, padding: '7px 14px', fontSize: 13 };
const deleteBtn = { background: 'transparent', border: '1px solid var(--color-red)', color: 'var(--color-red)', borderRadius: 8, padding: '7px 14px', fontSize: 13 };
const inputStyle = { background: '#0d0d0d', border: '1px solid var(--color-border)', borderRadius: 8, padding: '10px 12px', color: 'var(--color-white)', fontSize: 13, width: '100%' };