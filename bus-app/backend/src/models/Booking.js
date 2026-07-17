const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Booking = sequelize.define('Booking', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  // routeId is the real relational link to the Route table. routeName/
  // pickupStop/bookingDate/bookingTime are kept as a "snapshot" copy
  // taken at booking time — useful so a booking's history still reads
  // correctly even if the admin edits or deletes the route later.
  routeId: { type: DataTypes.UUID, allowNull: false },
  routeName: { type: DataTypes.STRING, allowNull: false },
  pickupStop: { type: DataTypes.STRING, allowNull: false },
  bookingDate: { type: DataTypes.DATEONLY, allowNull: false },
  bookingTime: { type: DataTypes.STRING, allowNull: false },
  seatCount: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
  isLocal: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  // totalFare and currency are ALWAYS computed server-side from the
  // Route's fare/internationalFare — never trusted from the client.
  totalFare: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  currency: { type: DataTypes.STRING, allowNull: false, defaultValue: 'UGX' },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  paymentMethodChosen: { type: DataTypes.STRING, allowNull: true },
  provider: { type: DataTypes.STRING, allowNull: true },
  phoneNumber: { type: DataTypes.STRING, allowNull: true },
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'paid', 'failed'),
    defaultValue: 'pending',
  },
  txRef: { type: DataTypes.STRING, allowNull: true, unique: true },
  providerTransactionId: { type: DataTypes.STRING, allowNull: true },
  userId: { type: DataTypes.UUID, allowNull: true },
  busId: { type: DataTypes.UUID, allowNull: true }, // assigned later by admin, not at booking time
}, {
  tableName: 'bookings',
  timestamps: true,
});

module.exports = Booking;