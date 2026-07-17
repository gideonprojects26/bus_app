const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Booking = sequelize.define('Booking', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  routeName: { type: DataTypes.STRING, allowNull: false },
  pickupStop: { type: DataTypes.STRING, allowNull: false },
  bookingDate: { type: DataTypes.DATEONLY, allowNull: false },
  bookingTime: { type: DataTypes.STRING, allowNull: false },
  seatCount: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
  isLocal: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  totalFare: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  currency: { type: DataTypes.STRING, allowNull: false, defaultValue: 'UGX' },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  paymentMethodChosen: { type: DataTypes.STRING, allowNull: true }, // 'mobile_money' or 'card' — what the USER picked
  provider: { type: DataTypes.STRING, allowNull: true }, // 'mtn_direct', 'airtel_direct', 'pesapal' — what the ROUTER decided
  phoneNumber: { type: DataTypes.STRING, allowNull: true }, // normalized, for mobile money bookings only
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'paid', 'failed'),
    defaultValue: 'pending',
  },
  txRef: { type: DataTypes.STRING, allowNull: true, unique: true },
  providerTransactionId: { type: DataTypes.STRING, allowNull: true },
  userId: { type: DataTypes.UUID, allowNull: true },
}, {
  tableName: 'bookings',
  timestamps: true,
});

module.exports = Booking;