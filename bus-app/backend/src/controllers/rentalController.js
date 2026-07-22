const { RentalRequest } = require('../models');
const { sendRentalRequestEmail } = require('../services/emailService');

const createRentalRequest = async (req, res) => {
  try {
    const { fullName, phone, passengerCount, neededDate, additionalDetails } = req.body;

    if (!fullName || !phone || !passengerCount || !neededDate) {
      return res.status(400).json({ message: 'All required fields must be filled.' });
    }

    // 1. Save to the database successfully
    const rental = await RentalRequest.create({
      fullName,
      phone,
      passengerCount,
      neededDate,
      additionalDetails,
      userId: req.user?.id || null,
    });

    // 2. Respond to the app IMMEDIATELY (Stops the loading spinner right away!)
    res.status(201).json({ message: 'Rental request submitted successfully.', rental });

    // 3. Trigger email in the background WITHOUT 'await'
    // If Render blocks the network port, it logs the error quietly 
    // in your server terminal without locking up your user's app.
    sendRentalRequestEmail(rental).catch((emailError) => {
      console.error('Background email failed to send:', emailError.message);
    });

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