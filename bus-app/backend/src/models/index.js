const sequelize = require('../config/database');
const User = require('./User');
const Driver = require('./Driver');
const Bus = require('./Bus');
const Route = require('./Route');
const Booking = require('./Booking');
const RentalRequest = require('./RentalRequest');

Driver.hasMany(Bus, { foreignKey: 'driverId' });
Bus.belongsTo(Driver, { foreignKey: 'driverId' });

Route.hasMany(Bus, { foreignKey: 'routeId' });
Bus.belongsTo(Route, { foreignKey: 'routeId' });

User.hasMany(Booking, { foreignKey: 'userId' });
Booking.belongsTo(User, { foreignKey: 'userId' });

Route.hasMany(Booking, { foreignKey: 'routeId' });
Booking.belongsTo(Route, { foreignKey: 'routeId' });

Bus.hasMany(Booking, { foreignKey: 'busId' });
Booking.belongsTo(Bus, { foreignKey: 'busId' });

User.hasMany(RentalRequest, { foreignKey: 'userId' });
RentalRequest.belongsTo(User, { foreignKey: 'userId' });

module.exports = {
  sequelize,
  User,
  Driver,
  Bus,
  Route,
  Booking,
  RentalRequest,
};