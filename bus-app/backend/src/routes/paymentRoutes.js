const express = require('express');
const router = express.Router();
const { 
  initiatePayment, 
  getPaymentStatus, 
  pesapalWebhook, 
  pesapalCallback 
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

router.post('/initiate', protect, initiatePayment);
router.get('/status/:txRef', protect, getPaymentStatus);
router.get('/pesapal/webhook', pesapalWebhook); // IPN listener
router.get('/pesapal-callback', pesapalCallback); // Redirect page after payment

module.exports = router;