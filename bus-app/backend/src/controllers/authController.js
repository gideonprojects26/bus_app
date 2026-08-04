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

// @route POST /api/auth/login (Riders Only — phone-based)
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

// @route POST /api/auth/admin-login (Admins Only — email-based)
// Kept entirely separate from rider login above: admins authenticate
// with email instead of phone, and this explicitly rejects any account
// that isn't role === 'admin', even if the email/password are otherwise correct.
const adminLogin = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: errors.array()[0].msg });
    }

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }

    const user = await User.findOne({ where: { email } });
    if (!user || user.role !== 'admin') {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const token = generateToken(user);

    res.status(200).json({
      message: 'Login successful.',
      token,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error during login.' });
  }
};

// @route POST /api/auth/create-admin (Protected — Admin Only)
// The only legitimate way a new admin account can ever be created.
// Requires email (used for admin login) and password; phone is optional
// for admin accounts since admins log in via email, not phone.
const createAdminAccount = async (req, res) => {
  try {
    const { fullName, email, phone, password } = req.body;

    if (!fullName || !email || !password) {
      return res.status(400).json({ message: 'Full name, email, and password are required.' });
    }

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({ message: 'Email already in use.' });
    }

    const admin = await User.create({
      fullName,
      email,
      phone: phone || null,
      password,
      role: 'admin',
    });

    res.status(201).json({
      message: 'Admin account created successfully.',
      user: {
        id: admin.id,
        fullName: admin.fullName,
        email: admin.email,
        role: admin.role,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error creating admin account.' });
  }
};

module.exports = { signup, login, adminLogin, createAdminAccount };