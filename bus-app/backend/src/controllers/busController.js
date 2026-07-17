const { Bus, Driver, Route } = require('../models');

exports.getAllBuses = async (req, res) => {
  try {
    const buses = await Bus.findAll({ include: [Driver, Route] });
    res.json(buses);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch buses.' });
  }
};

exports.getBusById = async (req, res) => {
  try {
    const bus = await Bus.findByPk(req.params.id, { include: [Driver, Route] });
    if (!bus) return res.status(404).json({ message: 'Bus not found.' });
    res.json(bus);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch bus.' });
  }
};

exports.createBus = async (req, res) => {
  try {
    const { plateNumber, capacity, routeId, driverId, status } = req.body;
    const bus = await Bus.create({
      plateNumber,
      capacity,
      routeId: routeId || null,
      driverId: driverId || null,
      status: status || 'idle',
    });
    res.status(201).json(bus);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create bus.' });
  }
};

exports.updateBus = async (req, res) => {
  try {
    const bus = await Bus.findByPk(req.params.id);
    if (!bus) return res.status(404).json({ message: 'Bus not found.' });
    await bus.update(req.body);
    res.json(bus);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update bus.' });
  }
};

exports.deleteBus = async (req, res) => {
  try {
    const bus = await Bus.findByPk(req.params.id);
    if (!bus) return res.status(404).json({ message: 'Bus not found.' });
    await bus.destroy();
    res.json({ message: 'Bus deleted.' });
  } catch (error) {
    res.status(500).json({ message: 'Failed to delete bus.' });
  }
};

// Used later by the mobile app tracking screen to update live location
exports.updateBusLocation = async (req, res) => {
  try {
    const { currentLat, currentLng } = req.body;
    const bus = await Bus.findByPk(req.params.id);
    if (!bus) return res.status(404).json({ message: 'Bus not found.' });
    await bus.update({ currentLat, currentLng });
    res.json(bus);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update location.' });
  }
};