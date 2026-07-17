import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import Modal from '../components/Modal';
import api from '../services/api';

const emptyForm = {
  name: '',
  description: '',
  startPoint: '',
  endPoint: '',
  fare: '',
  internationalFare: '',
  stops: [{ name: '', latitude: '', longitude: '' }],
  schedule: [{ day: '', departureTime: '' }],
};

export default function RoutesPage() {
  const [routes, setRoutes] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(emptyForm);
  const [loading, setLoading] = useState(false);

  const fetchRoutes = async () => {
    const res = await api.get('/routes');
    setRoutes(res.data);
  };

  useEffect(() => {
    fetchRoutes();
  }, []);

  const openCreate = () => {
    setForm(emptyForm);
    setEditingId(null);
    setShowModal(true);
  };

  const openEdit = (route) => {
    setForm({
      name: route.name,
      description: route.description || '',
      startPoint: route.startPoint,
      endPoint: route.endPoint,
      fare: route.fare,
      internationalFare: route.internationalFare || '',
      stops: route.stops?.length ? route.stops : emptyForm.stops,
      schedule: route.schedule?.length ? route.schedule : emptyForm.schedule,
    });
    setEditingId(route.id);
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this route?')) return;
    await api.delete(`/routes/${id}`);
    fetchRoutes();
  };

  const handleStopChange = (index, field, value) => {
    const updated = [...form.stops];
    updated[index][field] = value;
    setForm({ ...form, stops: updated });
  };

  const addStop = () => {
    setForm({ ...form, stops: [...form.stops, { name: '', latitude: '', longitude: '' }] });
  };

  const removeStop = (index) => {
    setForm({ ...form, stops: form.stops.filter((_, i) => i !== index) });
  };

  const handleScheduleChange = (index, field, value) => {
    const updated = [...form.schedule];
    updated[index][field] = value;
    setForm({ ...form, schedule: updated });
  };

  const addSchedule = () => {
    setForm({ ...form, schedule: [...form.schedule, { day: '', departureTime: '' }] });
  };

  const removeSchedule = (index) => {
    setForm({ ...form, schedule: form.schedule.filter((_, i) => i !== index) });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const payload = {
        ...form,
        fare: parseFloat(form.fare),
        internationalFare: parseFloat(form.internationalFare) || 30,
      };
      if (editingId) {
        await api.put(`/routes/${editingId}`, payload);
      } else {
        await api.post('/routes', payload);
      }
      setShowModal(false);
      fetchRoutes();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to save route.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Layout>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 28 }}>
        <div>
          <h1 style={{ marginBottom: 6 }}>Tour Routes</h1>
          <p style={{ color: 'var(--color-grey)' }}>Manage Religious Tour, City Highlights Tour, and their stops</p>
        </div>
        <button style={buttonStyle} onClick={openCreate}>+ New Route</button>
      </div>

      <div style={{ display: 'grid', gap: 16 }}>
        {routes.map((route) => (
          <div key={route.id} style={cardStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <div>
                <h3 style={{ marginBottom: 4 }}>{route.name}</h3>
                <p style={{ color: 'var(--color-grey)', fontSize: 13, marginBottom: 8 }}>{route.description}</p>
                <p style={{ fontSize: 13 }}>{route.startPoint} → {route.endPoint}</p>
                <div style={{ display: 'flex', gap: 16, marginTop: 4 }}>
                  <p style={{ fontSize: 13, color: 'var(--color-yellow)', fontWeight: 600 }}>
                    Local: UGX {route.fare}
                  </p>
                  <p style={{ fontSize: 13, color: 'var(--color-yellow)', fontWeight: 600 }}>
                    International: USD {route.internationalFare || 30}
                  </p>
                </div>
                <p style={{ fontSize: 12, color: 'var(--color-grey)', marginTop: 8 }}>
                  {route.stops?.length || 0} stops · {route.schedule?.length || 0} scheduled departures
                </p>
              </div>
              <div style={{ display: 'flex', gap: 8, height: 'fit-content' }}>
                <button style={editBtn} onClick={() => openEdit(route)}>Edit</button>
                <button style={deleteBtn} onClick={() => handleDelete(route.id)}>Delete</button>
              </div>
            </div>
          </div>
        ))}
        {routes.length === 0 && <p style={{ color: 'var(--color-grey)' }}>No routes yet. Create one to get started.</p>}
      </div>

      {showModal && (
        <Modal title={editingId ? 'Edit Route' : 'New Route'} onClose={() => setShowModal(false)}>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <input style={inputStyle} placeholder="Route Name (e.g. Religious Tour)" value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })} required />
            <textarea style={{ ...inputStyle, minHeight: 60 }} placeholder="Description" value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })} />
            <input style={inputStyle} placeholder="Start Point" value={form.startPoint}
              onChange={(e) => setForm({ ...form, startPoint: e.target.value })} required />
            <input style={inputStyle} placeholder="End Point" value={form.endPoint}
              onChange={(e) => setForm({ ...form, endPoint: e.target.value })} required />
            <input style={inputStyle} placeholder="Local Fare (UGX)" type="number" value={form.fare}
              onChange={(e) => setForm({ ...form, fare: e.target.value })} required />
            <input style={inputStyle} placeholder="International Fare (USD)" type="number" value={form.internationalFare}
              onChange={(e) => setForm({ ...form, internationalFare: e.target.value })} required />

            <label style={sectionLabel}>Stops</label>
            {form.stops.map((stop, i) => (
              <div key={i} style={{ display: 'flex', gap: 8 }}>
                <input style={inputStyle} placeholder="Stop name" value={stop.name}
                  onChange={(e) => handleStopChange(i, 'name', e.target.value)} />
                <input style={{ ...inputStyle, width: 90 }} placeholder="Lat" value={stop.latitude}
                  onChange={(e) => handleStopChange(i, 'latitude', e.target.value)} />
                <input style={{ ...inputStyle, width: 90 }} placeholder="Lng" value={stop.longitude}
                  onChange={(e) => handleStopChange(i, 'longitude', e.target.value)} />
                <button type="button" style={removeBtn} onClick={() => removeStop(i)}>×</button>
              </div>
            ))}
            <button type="button" style={addBtn} onClick={addStop}>+ Add Stop</button>

            <label style={sectionLabel}>Schedule</label>
            {form.schedule.map((s, i) => (
              <div key={i} style={{ display: 'flex', gap: 8 }}>
                <input style={inputStyle} placeholder="Day (e.g. Monday)" value={s.day}
                  onChange={(e) => handleScheduleChange(i, 'day', e.target.value)} />
                <input style={inputStyle} placeholder="Time (e.g. 08:00)" value={s.departureTime}
                  onChange={(e) => handleScheduleChange(i, 'departureTime', e.target.value)} />
                <button type="button" style={removeBtn} onClick={() => removeSchedule(i)}>×</button>
              </div>
            ))}
            <button type="button" style={addBtn} onClick={addSchedule}>+ Add Schedule Slot</button>

            <button style={buttonStyle} type="submit" disabled={loading}>
              {loading ? 'Saving...' : editingId ? 'Update Route' : 'Create Route'}
            </button>
          </form>
        </Modal>
      )}
    </Layout>
  );
}

const buttonStyle = {
  background: 'var(--color-yellow)',
  color: 'var(--color-black)',
  border: 'none',
  borderRadius: 10,
  padding: '11px 20px',
  fontWeight: 'bold',
  fontSize: 14,
};

const cardStyle = {
  background: 'var(--color-black-light)',
  border: '1px solid var(--color-border)',
  borderRadius: 14,
  padding: 20,
};

const editBtn = {
  background: 'transparent',
  border: '1px solid var(--color-yellow)',
  color: 'var(--color-yellow)',
  borderRadius: 8,
  padding: '7px 14px',
  fontSize: 13,
};

const deleteBtn = {
  background: 'transparent',
  border: '1px solid var(--color-red)',
  color: 'var(--color-red)',
  borderRadius: 8,
  padding: '7px 14px',
  fontSize: 13,
};

const inputStyle = {
  background: '#0d0d0d',
  border: '1px solid var(--color-border)',
  borderRadius: 8,
  padding: '10px 12px',
  color: 'var(--color-white)',
  fontSize: 13,
  width: '100%',
};

const sectionLabel = { fontSize: 12, color: 'var(--color-yellow)', fontWeight: 600, marginTop: 6 };

const addBtn = {
  background: 'transparent',
  border: '1px dashed var(--color-yellow)',
  color: 'var(--color-yellow)',
  borderRadius: 8,
  padding: '8px',
  fontSize: 12,
};

const removeBtn = {
  background: 'var(--color-red)',
  color: 'var(--color-white)',
  border: 'none',
  borderRadius: 8,
  width: 32,
  fontSize: 16,
};