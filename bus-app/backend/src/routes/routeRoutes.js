const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload'); // Bring in Multer from Step 4
const routeController = require('../controllers/routeController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

// Public endpoints — normal bus riders can view routes and stops without logging in
router.get('/', routeController.getAllRoutes);
router.get('/:id', routeController.getRouteById);
// Notice upload.single('image') — this tells Multer to intercept the file named 'image'
router.post('/upload', upload.single('image'), routeController.uploadImage);

// Protected Admin endpoints — requires a valid JWT token AND admin privileges
router.post('/', protect, adminOnly, routeController.createRoute);
router.put('/:id', protect, adminOnly, routeController.updateRoute);
router.delete('/:id', protect, adminOnly, routeController.deleteRoute);

module.exports = router;