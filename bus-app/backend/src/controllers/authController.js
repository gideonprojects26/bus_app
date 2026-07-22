const { User } = require('../models');
const generateToken = require('../utils/generateToken');

// @route POST /api/auth/signup (Riders Only)
const signup = async (req, res) => {
  try {
    const { fullName, phone, password } = req.body;

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
    const { phone, password } = req.body;

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