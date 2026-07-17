import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import Modal from '../components/Modal';
import api from '../services/api';

const emptyForm = { fullName: '', phone: '', licenseNumber: '', status: 'active' };

export default function DriversPage() {
  const [drivers, setDrivers] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(emptyForm);

  const fetchDrivers = async () => {
    const res = await api.get('/drivers');
    setDrivers(res.data);
  };

  useEffect(() => { fetchDrivers(); }, []);

  const openCreate = () => {
    setForm(emptyForm);
    setEditingId(null);
    setShowModal(true);
  };

  const openEdit = (driver) => {
    setForm({ fullName: driver.fullName, phone: driver.phone, licenseNumber: driver.licenseNumber, status: driver.status });
    setEditingId(driver.id);
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this driver?')) return;
    await api.delete(`/drivers/${id}`);
    fetchDrivers();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (editingId) {
      await api.put(`/drivers/${editingId}`, form);
    } else {
      await api.post('/drivers', form);
    }
    setShowModal(false);
    fetchDrivers();
  };

  return (
    <Layout>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 28 }}>
        <div>
          <h1 style={{ marginBottom: 6 }}>Drivers</h1>
          <p style={{ color: 'var(--color-grey)' }}>Manage driver accounts</p>
        </div>
        <button style={buttonStyle} onClick={openCreate}>+ New Driver</button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
        {drivers.map((driver) => (
          <div key={driver.id} style={cardStyle}>
            <h3>{driver.fullName}</h3>
            <p style={{ fontSize: 13, color: 'var(--color-grey)', marginTop: 6 }}>{driver.phone}</p>
            <p style={{ fontSize: 13, color: 'var(--color-grey)' }}>License: {driver.licenseNumber}</p>
            <p style={{ fontSize: 13, marginTop: 4 }}>Status: <span style={{ color: driver.status === 'active' ? 'var(--color-yellow)' : 'var(--color-red)' }}>{driver.status}</span></p>
            <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
              <button style={editBtn} onClick={() => openEdit(driver)}>Edit</button>
              <button style={deleteBtn} onClick={() => handleDelete(driver.id)}>Delete</button>
            </div>
          </div>
        ))}
        {drivers.length === 0 && <p style={{ color: 'var(--color-grey)' }}>No drivers yet.</p>}
      </div>

      {showModal && (
        <Modal title={editingId ? 'Edit Driver' : 'New Driver'} onClose={() => setShowModal(false)}>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <input style={inputStyle} placeholder="Full Name" value={form.fullName}
              onChange={(e) => setForm({ ...form, fullName: e.target.value })} required />
            <input style={inputStyle} placeholder="Phone Number" value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })} required />
            <input style={inputStyle} placeholder="License Number" value={form.licenseNumber}
              onChange={(e) => setForm({ ...form, licenseNumber: e.target.value })} required />
            <select style={inputStyle} value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value })}>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="suspended">Suspended</option>
            </select>
            <button style={buttonStyle} type="submit">{editingId ? 'Update Driver' : 'Create Driver'}</button>
          </form>
        </Modal>
      )}
    </Layout>
  );
}

const buttonStyle = { background: 'var(--color-yellow)', color: 'var(--color-black)', border: 'none', borderRadius: 10, padding: '11px 20px', fontWeight: 'bold', fontSize: 14 };
const cardStyle = { background: 'var(--color-black-light)', border: '1px solid var(--color-border)', borderRadius: 14, padding: 18 };
const editBtn = { background: 'transparent', border: '1px solid var(--color-yellow)', color: 'var(--color-yellow)', borderRadius: 8, padding: '7px 14px', fontSize: 13 };
const deleteBtn = { background: 'transparent', border: '1px solid var(--color-red)', color: 'var(--color-red)', borderRadius: 8, padding: '7px 14px', fontSize: 13 };
const inputStyle = { background: '#0d0d0d', border: '1px solid var(--color-border)', borderRadius: 8, padding: '10px 12px', color: 'var(--color-white)', fontSize: 13, width: '100%' };