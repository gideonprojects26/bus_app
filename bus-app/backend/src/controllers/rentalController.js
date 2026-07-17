const { RentalRequest } = require('../models');
const { sendRentalRequestEmail } = require('../services/emailService');

// Rider submits a rental inquiry from the app. Saved to the database
// (so it shows on the admin dashboard) AND emailed to the admin team,
// as requested — the two happen independently, so if email delivery
// fails, the request is still safely saved and visible on the dashboard.
const createRentalRequest = async (req, res) => {
  try {
    const { fullName, phone, passengerCount, neededDate, additionalDetails } = req.body;

    if (!fullName || !phone || !passengerCount || !neededDate) {
      return res.status(400).json({ message: 'All required fields must be filled.' });
    }

    const rental = await RentalRequest.create({
      fullName,
      phone,
      passengerCount,
      neededDate,
      additionalDetails,
      userId: req.user?.id || null,
    });

    try {
      await sendRentalRequestEmail(rental);
    } catch (emailError) {
      // Log but don't fail the whole request just because email didn't
      // send — the rental request itself is still safely recorded.
      console.error('Rental request email failed to send:', emailError.message);
    }

    res.status(201).json({ message: 'Rental request submitted successfully.', rental });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error submitting rental request.' });
  }
};

const getAllRentalRequests = async (req, res) => {
  try {
    const rentals = await RentalRequest.findAll({ order: [['createdAt', 'DESC']] });
    res.json(rentals);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch rental requests.' });
  }
};

const updateRentalRequestStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const rental = await RentalRequest.findByPk(req.params.id);
    if (!rental) return res.status(404).json({ message: 'Rental request not found.' });
    await rental.update({ status });
    res.json(rental);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update rental request.' });
  }
};

module.exports = { createRentalRequest, getAllRentalRequests, updateRentalRequestStatus };