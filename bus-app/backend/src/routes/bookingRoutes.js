const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.get('/', protect, adminOnly, bookingController.getAllBookings);
router.get('/my-bookings', protect, bookingController.getMyBookings);
router.post('/', protect, bookingController.createBooking);
router.patch('/:id/status', protect, adminOnly, bookingController.updateBookingStatus);
router.patch('/:id/cancel', protect, bookingController.cancelBooking);

module.exports = router;