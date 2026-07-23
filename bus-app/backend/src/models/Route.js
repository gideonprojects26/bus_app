// src/models/route.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Route = sequelize.define('Route', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: { type: DataTypes.STRING, allowNull: false },
  description: { type: DataTypes.TEXT, allowNull: true },
  startPoint: { type: DataTypes.STRING, allowNull: false },
  endPoint: { type: DataTypes.STRING, allowNull: false },
  fare: { type: DataTypes.DECIMAL(12, 2), allowNull: false, defaultValue: 50000 },
  internationalFare: { type: DataTypes.DECIMAL(10, 2), allowNull: false, defaultValue: 30 },
  stops: { type: DataTypes.JSONB, defaultValue: [] },
  schedule: { type: DataTypes.JSONB, defaultValue: [] },
  images: { type: DataTypes.JSONB, defaultValue: [] }, // <--- Stores list of {path, caption} objects
}, {
  tableName: 'routes',
  timestamps: true,
});

module.exports = Route;