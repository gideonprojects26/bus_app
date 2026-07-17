const express = require('express');
const router = express.Router();
const routeController = require('../controllers/routeController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.get('/', routeController.getAllRoutes);
router.get('/:id', routeController.getRouteById);
router.post('/', protect, adminOnly, routeController.createRoute);
router.put('/:id', protect, adminOnly, routeController.updateRoute);
router.delete('/:id', protect, adminOnly, routeController.deleteRoute);

module.exports = router;