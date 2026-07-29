const { Route } = require('../models');
const cloudinary = require('../config/cloudinary');
const fs = require('fs'); // Node's built-in File System module to clean up temp files

/**
 * FETCH ALL ROUTES
 * Returns all routes from PostgreSQL. The 'stops' JSON column is automatically
 * parsed by Sequelize so Flutter receives it as a clean list of stop objects.
 */
exports.getAllRoutes = async (req, res) => {
  try {
    const routes = await Route.findAll({
      order: [['id', 'ASC']], // Keeps the tour list in a consistent order
    });
    res.status(200).json(routes);
  } catch (error) {
    console.error('Error fetching routes:', error);
    res.status(500).json({ message: 'Failed to fetch routes.' });
  }
};

/**
 * FETCH SINGLE ROUTE BY ID
 * Used when the Flutter app opens the RouteDetailScreen to get fresh data.
 */
exports.getRouteById = async (req, res) => {
  try {
    const route = await Route.findByPk(req.params.id);
    if (!route) {
      return res.status(404).json({ message: 'Route not found.' });
    }
    res.status(200).json(route);
  } catch (error) {
    console.error(`Error fetching route ID ${req.params.id}:`, error);
    res.status(500).json({ message: 'Failed to fetch route details.' });
  }
};

/**
 * CREATE A NEW ROUTE (Admin Dashboard Only)
 */
exports.createRoute = async (req, res) => {
  try {
    const { name, description, startPoint, endPoint, fare, stops, schedule } = req.body;
    
    // Sequelize stores the 'stops' array directly into the PostgreSQL JSONB/JSON column
    const route = await Route.create({ 
      name, 
      description, 
      startPoint, 
      endPoint, 
      fare, 
      stops, 
      schedule 
    });
    
    res.status(201).json(route);
  } catch (error) {
    console.error('Error creating route:', error);
    res.status(500).json({ message: 'Failed to create route.' });
  }
};

/**
 * UPDATE AN EXISTING ROUTE (Admin Dashboard Only)
 */
exports.updateRoute = async (req, res) => {
  try {
    const route = await Route.findByPk(req.params.id);
    if (!route) {
      return res.status(404).json({ message: 'Route not found.' });
    }
    
    await route.update(req.body);
    res.status(200).json(route);
  } catch (error) {
    console.error(`Error updating route ID ${req.params.id}:`, error);
    res.status(500).json({ message: 'Failed to update route.' });
  }
};

/**
 * DELETE A ROUTE (Admin Dashboard Only)
 */
exports.deleteRoute = async (req, res) => {
  try {
    const route = await Route.findByPk(req.params.id);
    if (!route) {
      return res.status(404).json({ message: 'Route not found.' });
    }
    
    await route.destroy();
    res.status(200).json({ message: 'Route deleted successfully.' });
  } catch (error) {
    console.error(`Error deleting route ID ${req.params.id}:`, error);
    res.status(500).json({ message: 'Failed to delete route.' });
  }
};

exports.uploadImage = async (req, res) => {
  try {
    // 1. Check if Multer caught a file in the request
    if (!req.file) {
      return res.status(400).json({ message: 'No image file provided.' });
    }

    // 2. Upload the file from your Render temp folder to Cloudinary
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: 'bus-app/tours', // Automatically creates a neat folder in Cloudinary
    });

    // 3. Clean up: Delete the temporary file from your Render server's disk
    fs.unlinkSync(req.file.path);

    // 4. Return the permanent, public Cloudinary URL to the frontend!
    res.status(200).json({
      success: true,
      message: 'Image uploaded successfully!',
      imageUrl: result.secure_url,
    });
  } catch (error) {
    console.error('Cloudinary Upload Error:', error);
    
    // If an error happens, try to clean up the local temp file so your server doesn't get clogged
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    
    res.status(500).json({ message: 'Failed to upload image to Cloudinary.' });
  }
};