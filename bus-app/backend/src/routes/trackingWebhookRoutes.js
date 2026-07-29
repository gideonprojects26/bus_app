const express = require('express');
const router = express.Router();
const { receiveLocationUpdate } = require('../controllers/trackingWebhookController');

// No 'protect' middleware — this is called by TrackNav's server, not
// a logged-in user. Security instead comes from the shared secret
// check inside the controller itself.
router.post('/webhook', receiveLocationUpdate);

module.exports = router;