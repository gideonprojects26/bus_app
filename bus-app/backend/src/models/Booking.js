const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Helper function to generate custom string IDs in the format: KSB-XXXXXX
 * Excludes easily confused characters like 0, O, 1, and I.
 */
function generateKsbBookingId() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let randomPart = '';
  for (let i = 0; i < 6; i++) {
    randomPart += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `KSB-${randomPart}`; // Example output: "KSB-9X2K7M"
}

const Booking = sequelize.define('Booking', {
  // Custom primary key (VARCHAR 50).
  // defaultValue guarantees an ID is generated even if missing in create()
  id: {
    type: DataTypes.STRING(50),
    primaryKey: true,
    defaultValue: () => generateKsbBookingId(),
  },

  // Foreign Key to the Routes table
  routeId: { 
    type: DataTypes.UUID, 
    allowNull: false 
  },

  // Historical snapshot fields (retained even if the original route changes later)
  routeName: { type: DataTypes.STRING, allowNull: false },
  pickupStop: { type: DataTypes.STRING, allowNull: false },
  bookingDate: { type: DataTypes.DATEONLY, allowNull: false },
  bookingTime: { type: DataTypes.STRING, allowNull: false },
  seatCount: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 1 },
  isLocal: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },

  // Fare calculation fields (computed server-side, never trusted from client)
  totalFare: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  currency: { type: DataTypes.STRING, allowNull: false, defaultValue: 'UGX' },

  // Overall booking process status
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },

  // Payment gateway metadata
  paymentMethodChosen: { type: DataTypes.STRING, allowNull: true }, // e.g., "mobile_money", "card"
  provider: { type: DataTypes.STRING, allowNull: true },            // e.g., "mtn_direct", "pesapal"
  phoneNumber: { type: DataTypes.STRING, allowNull: true },
  paymentStatus: {
    type: DataTypes.ENUM('pending', 'paid', 'failed'),
    defaultValue: 'pending',
  },
  
  // Unique transaction reference sent to payment gateways
  txRef: { type: DataTypes.STRING, allowNull: true, unique: true },
  
  // External gateway transaction tracking ID (e.g., Pesapal Order Tracking ID)
  providerTransactionId: { type: DataTypes.STRING, allowNull: true },

  // Foreign keys for User and assigned Bus
  userId: { type: DataTypes.UUID, allowNull: true },
  busId: { type: DataTypes.UUID, allowNull: true }, // Assigned later by admin
}, {
  tableName: 'bookings',
  timestamps: true, // Automatically manages createdAt and updatedAt
});

module.exports = Booking;