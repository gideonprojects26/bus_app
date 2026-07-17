const express = require('express');
const router = express.Router();
const { createRentalRequest, getAllRentalRequests, updateRentalRequestStatus } = require('../controllers/rentalController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.post('/', protect, createRentalRequest);
router.get('/', protect, adminOnly, getAllRentalRequests);
router.patch('/:id/status', protect, adminOnly, updateRentalRequestStatus);

module.exports = router;