const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const RentalRequest = sequelize.define('RentalRequest', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  fullName: { type: DataTypes.STRING, allowNull: false },
  phone: { type: DataTypes.STRING, allowNull: false },
  passengerCount: { type: DataTypes.INTEGER, allowNull: false },
  neededDate: { type: DataTypes.DATEONLY, allowNull: false },
  additionalDetails: { type: DataTypes.TEXT, allowNull: true },
  status: {
    type: DataTypes.ENUM('pending', 'contacted', 'confirmed', 'declined'),
    defaultValue: 'pending',
  },
  userId: { type: DataTypes.UUID, allowNull: true },
}, {
  tableName: 'rental_requests',
  timestamps: true,
});

module.exports = RentalRequest;