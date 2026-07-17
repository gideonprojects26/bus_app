const { Driver } = require('../models');

exports.getAllDrivers = async (req, res) => {
  try {
    const drivers = await Driver.findAll();
    res.json(drivers);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch drivers.' });
  }
};

exports.getDriverById = async (req, res) => {
  try {
    const driver = await Driver.findByPk(req.params.id);
    if (!driver) return res.status(404).json({ message: 'Driver not found.' });
    res.json(driver);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch driver.' });
  }
};

exports.createDriver = async (req, res) => {
  try {
    const { fullName, phone, licenseNumber, status } = req.body;
    const driver = await Driver.create({ fullName, phone, licenseNumber, status });
    res.status(201).json(driver);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create driver.' });
  }
};

exports.updateDriver = async (req, res) => {
  try {
    const driver = await Driver.findByPk(req.params.id);
    if (!driver) return res.status(404).json({ message: 'Driver not found.' });
    await driver.update(req.body);
    res.json(driver);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update driver.' });
  }
};

exports.deleteDriver = async (req, res) => {
  try {
    const driver = await Driver.findByPk(req.params.id);
    if (!driver) return res.status(404).json({ message: 'Driver not found.' });
    await driver.destroy();
    res.json({ message: 'Driver deleted.' });
  } catch (error) {
    res.status(500).json({ message: 'Failed to delete driver.' });
  }
};