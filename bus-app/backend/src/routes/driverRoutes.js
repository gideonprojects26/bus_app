const express = require('express');
const router = express.Router();
const driverController = require('../controllers/driverController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.get('/', protect, adminOnly, driverController.getAllDrivers);
router.get('/:id', protect, adminOnly, driverController.getDriverById);
router.post('/', protect, adminOnly, driverController.createDriver);
router.put('/:id', protect, adminOnly, driverController.updateDriver);
router.delete('/:id', protect, adminOnly, driverController.deleteDriver);

module.exports = router;