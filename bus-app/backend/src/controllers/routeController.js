const { Route } = require('../models');

exports.getAllRoutes = async (req, res) => {
  try {
    const routes = await Route.findAll();
    res.json(routes);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch routes.' });
  }
};

exports.getRouteById = async (req, res) => {
  try {
    const route = await Route.findByPk(req.params.id);
    if (!route) return res.status(404).json({ message: 'Route not found.' });
    res.json(route);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch route.' });
  }
};

exports.createRoute = async (req, res) => {
  try {
    const { name, description, startPoint, endPoint, fare, stops, schedule } = req.body;
    const route = await Route.create({ name, description, startPoint, endPoint, fare, stops, schedule });
    res.status(201).json(route);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create route.' });
  }
};

exports.updateRoute = async (req, res) => {
  try {
    const route = await Route.findByPk(req.params.id);
    if (!route) return res.status(404).json({ message: 'Route not found.' });
    await route.update(req.body);
    res.json(route);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update route.' });
  }
};

exports.deleteRoute = async (req, res) => {
  try {
    const route = await Route.findByPk(req.params.id);
    if (!route) return res.status(404).json({ message: 'Route not found.' });
    await route.destroy();
    res.json({ message: 'Route deleted.' });
  } catch (error) {
    res.status(500).json({ message: 'Failed to delete route.' });
  }
};