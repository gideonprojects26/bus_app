const express = require('express');
const router = express.Router();
const busController = require('../controllers/busController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.get('/', busController.getAllBuses);
router.get('/:id', busController.getBusById);
router.post('/', protect, adminOnly, busController.createBus);
router.put('/:id', protect, adminOnly, busController.updateBus);
router.delete('/:id', protect, adminOnly, busController.deleteBus);
router.patch('/:id/location', busController.updateBusLocation);

module.exports = router;