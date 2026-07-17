const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Bus = sequelize.define('Bus', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  plateNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
  capacity: { type: DataTypes.INTEGER, allowNull: false },
  currentLat: { type: DataTypes.DOUBLE, allowNull: true },
  currentLng: { type: DataTypes.DOUBLE, allowNull: true },
  status: {
    type: DataTypes.ENUM('on_route', 'idle', 'maintenance'),
    defaultValue: 'idle',
  },
  routeId: { type: DataTypes.UUID, allowNull: true },
  driverId: { type: DataTypes.UUID, allowNull: true },
}, {
  tableName: 'buses',
  timestamps: true,
});

module.exports = Bus;