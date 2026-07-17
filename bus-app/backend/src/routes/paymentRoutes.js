const express = require('express');
const router = express.Router();
const { initiatePayment, getPaymentStatus, pesapalWebhook } = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

router.post('/initiate', protect, initiatePayment);
router.get('/status/:txRef', protect, getPaymentStatus);
router.get('/pesapal/webhook', pesapalWebhook); // no auth — called by PesaPal itself

module.exports = router;