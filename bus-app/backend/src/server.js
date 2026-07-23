const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { sequelize } = require('./models');

const authRoutes = require('./routes/authRoutes');
const routeRoutes = require('./routes/routeRoutes');
const busRoutes = require('./routes/busRoutes');
const driverRoutes = require('./routes/driverRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const rentalRoutes = require('./routes/rentalRoutes');
const paymentRoutes = require('./routes/paymentRoutes'); // 👈 1. Added payment routes

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Bus App API is running' });
});

app.use('/api/auth', authRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/buses', busRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/rentals', rentalRoutes);
app.use('/api/payments', paymentRoutes); // 👈 2. Mounted payment endpoint at /api/payments

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // 1. Verify connection to the database
    await sequelize.authenticate();
    console.log('Database connected successfully.');

    // 2. Safe sync: creates missing tables without dropping or wiping existing data
    await sequelize.sync();
    console.log('Database synced safely.');

    // 2b. Auto-fix: Ensure email column allows NULL in production DB
    try {
      await sequelize.query('ALTER TABLE "users" ALTER COLUMN "email" DROP NOT NULL;');
      console.log('✅ Database fix applied: "email" column is now optional!');
    } catch (fixErr) {
      console.log('DB constraint check completed.');
    }

    // 3. Bind explicitly to '0.0.0.0' and dynamic PORT for Render deployment
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Fatal DB connection error on startup:', err);
    process.exit(1);
  }
}

startServer();