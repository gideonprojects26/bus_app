const { User } = require('../models');
const generateToken = require('../utils/generateToken');
// NEW: Import validationResult to check for validation errors from the route middleware
const { validationResult } = require('express-validator');


// @route POST /api/auth/signup (Riders Only)
const signup = async (req, res) => {
  try {
    // NEW: Check if express-validator found any errors in the request
    // validationResult(req) pulls all errors collected by the body() rules
    // defined in authRoutes.js. If any rule failed, we stop here with a 400.
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      // Return only the first error message to keep the Flutter app's
      // error handling simple — one clear message at a time
      return res.status(400).json({ message: errors.array()[0].msg });
    }

    const { fullName, phone, password } = req.body;

    // NOTE: The manual check below is now redundant because express-validator
    // already enforces these fields in the route. We keep it as a safety net
    // in case the middleware is accidentally removed.
    if (!fullName || !phone || !password) {
      return res.status(400).json({ message: 'Full name, phone number, and password are required.' });
    }

    const existingUser = await User.findOne({ where: { phone } });
    if (existingUser) {
      return res.status(409).json({ message: 'Phone number already in use.' });
    }

    const user = await User.create({
      fullName,
      phone,
      password,
      role: 'rider', // Standard users always default to rider
    });

    const token = generateToken(user);

    res.status(201).json({
      message: 'Account created successfully.',
      token,
      user: {
        id: user.id,
        fullName: user.fullName,
        phone: user.phone,
        role: user.role,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error during signup.' });
  }
};

// @route POST /api/auth/login
const login = async (req, res) => {
  try {
    // NEW: Same validation check as signup — ensures phone and password
    // are present before we even touch the database
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: errors.array()[0].msg });
    }

    const { phone, password } = req.body;

    // Redundant manual check kept as safety net (see signup comment above)
    if (!phone || !password) {
      return res.status(400).json({ message: 'Phone number and password are required.' });
    }

    const user = await User.findOne({ where: { phone } });
    if (!user) {
      return res.status(401).json({ message: 'Invalid phone number or password.' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid phone number or password.' });
    }

    const token = generateToken(user);

    res.status(200).json({
      message: 'Login successful.',
      token,
      user: {
        id: user.id,
        fullName: user.fullName,
        phone: user.phone,
        role: user.role,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error during login.' });
  }
};

module.exports = { signup, login };