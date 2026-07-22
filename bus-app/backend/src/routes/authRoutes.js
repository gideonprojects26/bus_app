const express = require('express');
const router = express.Router();
const { signup, login } = require('../controllers/authController');

// Clean and simple auth routes for riders/app users
router.post('/signup', signup);
router.post('/login', login);

module.exports = router;