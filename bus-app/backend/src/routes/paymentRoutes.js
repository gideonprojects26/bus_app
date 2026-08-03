const express = require('express');
const router = express.Router();
// NEW: Import body() from express-validator to validate payment request fields
// This prevents the controller from processing payments with missing or invalid data
const { body } = require('express-validator');
const { 
  initiatePayment, 
  getPaymentStatus, 
  pesapalWebhook, 
  pesapalCallback 
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

// ---------- INITIATE PAYMENT ROUTE ----------
// protect middleware runs FIRST (verifies the JWT token), then
// validation rules run SECOND (checks the request body), then
// the controller runs LAST (processes the payment)
router.post(
  '/initiate',
  protect,
  [
    // routeId: Must be present — identifies which tour route is being booked
    body('routeId')
      .notEmpty()
      .withMessage('Route is required.'),

    // pickupStop: Must be present — where the passenger will be picked up
    body('pickupStop')
      .notEmpty()
      .withMessage('Pickup stop is required.'),

    // paymentMethodChosen: Must be exactly 'card' or 'mobile_money'
    // This prevents invalid payment types from reaching the payment processor
    body('paymentMethodChosen')
      .isIn(['card', 'mobile_money'])
      .withMessage('Invalid payment method.'),

    // seatCount: Optional field, but if provided must be an integer between 1-50
    // Prevents booking 0 seats or unrealistically large groups in a single booking
    body('seatCount')
      .optional()
      .isInt({ min: 1, max: 50 })
      .withMessage('Invalid passenger count.'),
  ],
  initiatePayment
);

// These routes don't need body validation since they use URL parameters or are webhooks
router.get('/status/:txRef', protect, getPaymentStatus);
router.get('/pesapal/webhook', pesapalWebhook); // IPN listener — PesaPal sends data, we don't validate external services
router.get('/pesapal-callback', pesapalCallback); // Redirect page after payment — no body data to validate

module.exports = router;