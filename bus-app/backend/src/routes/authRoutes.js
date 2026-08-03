const express = require('express');
const router = express.Router();
// NEW: Import body() from express-validator to define validation rules
// body() creates a middleware chain that validates specific fields in req.body
const { body } = require('express-validator');
const { signup, login } = require('../controllers/authController');

// ---------- SIGNUP ROUTE ----------
// Validation rules run BEFORE the controller function.
// If any rule fails, errors are collected and the controller
// checks them with validationResult(req) before processing.
router.post(
  '/signup',
  [
    // fullName: Must be a trimmed string between 2-100 characters
    // trim() removes leading/trailing whitespace so "  John  " becomes "John"
    body('fullName')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Full name must be 2-100 characters.'),

    // phone: Must be between 9-15 characters (covers local and international formats)
    // Examples: "0771234567" (10 chars), "+256771234567" (13 chars)
    body('phone')
      .trim()
      .isLength({ min: 9, max: 15 })
      .withMessage('Enter a valid phone number.'),

    // password: Must be at least 6 characters, max 72 (bcrypt limit)
    // 6 is the minimum for basic security; 72 is bcrypt's maximum input length
    body('password')
      .isLength({ min: 6, max: 72 })
      .withMessage('Password must be at least 6 characters.'),
  ],
  signup
);

// ---------- LOGIN ROUTE ----------
// Simpler validation — just ensure the fields are present
router.post(
  '/login',
  [
    // phone: Just needs to be present (not empty after trimming)
    body('phone')
      .trim()
      .notEmpty()
      .withMessage('Phone number is required.'),

    // password: Just needs to be present
    body('password')
      .notEmpty()
      .withMessage('Password is required.'),
  ],
  login
);

module.exports = router;