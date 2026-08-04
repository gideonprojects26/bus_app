const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { signup, login, createAdminAccount, adminLogin } = require('../controllers/authController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

// ---------- USER SIGNUP ROUTE ----------
// Validation rules run BEFORE the controller function.
router.post(
  '/signup',
  [
    // fullName: Must be a trimmed string between 2-100 characters
    body('fullName')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Full name must be 2-100 characters.'),

    // phone: Must be between 9-15 characters (covers local and international formats)
    body('phone')
      .trim()
      .isLength({ min: 9, max: 15 })
      .withMessage('Enter a valid phone number.'),

    // password: Must be at least 6 characters, max 72 (bcrypt limit)
    body('password')
      .isLength({ min: 6, max: 72 })
      .withMessage('Password must be at least 6 characters.'),
  ],
  signup
);

// ---------- USER LOGIN ROUTE ----------
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

// ---------- ADMIN LOGIN ROUTE ----------
router.post(
  '/admin-login',
  [
    // email: Must be a valid email format for admin accounts
    body('email')
      .isEmail()
      .withMessage('Enter a valid email.'),

    // password: Must be present
    body('password')
      .notEmpty()
      .withMessage('Password is required.'),
  ],
  adminLogin
);

// ---------- CREATE ADMIN ROUTE (Protected & Admin-Only) ----------
router.post(
  '/create-admin',
  /*protect,
  adminOnly,*/
  [
    body('fullName')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Full name must be 2-100 characters.'),
    body('email')
      .isEmail()
      .withMessage('Enter a valid email.'),
    body('password')
      .isLength({ min: 6, max: 72 })
      .withMessage('Password must be at least 6 characters.'),
  ],
  createAdminAccount
);

module.exports = router;