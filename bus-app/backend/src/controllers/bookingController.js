const { Booking, User, Bus } = require('../models');

exports.getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({ include: [User, Bus] });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch bookings.' });
  }
};

exports.getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      where: { userId: req.user.id },
      include: [Bus],
      order: [['createdAt', 'DESC']],
    });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch your bookings.' });
  }
};

exports.createBooking = async (req, res) => {
  try {
    const { busId, seatCount, totalFare } = req.body;
    const booking = await Booking.create({
      userId: req.user.id,
      busId,
      seatCount,
      totalFare,
      status: 'pending',
    });
    res.status(201).json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to create booking.' });
  }
};

exports.updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found.' });
    await booking.update({ status });
    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: 'Failed to update booking status.' });
  }
};

exports.cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found.' });

    if (booking.userId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to cancel this booking.' });
    }

    await booking.update({ status: 'cancelled' });
    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: 'Failed to cancel booking.' });
  }
};