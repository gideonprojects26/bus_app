const { Booking, Route } = require('../models');
const { decideProvider } = require('../services/providerRouter');
const pesapalService = require('../services/pesapalService');
const momoService = require('../services/momoService');

/**
 * Helper function to generate custom string IDs in format: KSB-XXXXXX
 * Excludes confusing characters (0, O, 1, I).
 */
function generateKsbBookingId() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let randomPart = '';
  for (let i = 0; i < 6; i++) {
    randomPart += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `KSB-${randomPart}`; // e.g., "KSB-9X2K7M"
}

/**
 * Initiates payment for a bus booking (MTN MoMo, Airtel Money, or Pesapal)
 */
const initiatePayment = async (req, res) => {
  try {
    const {
      routeId, pickupStop, bookingDate, bookingTime,
      seatCount, isLocal, paymentMethodChosen, phoneNumber, email,
    } = req.body;

    // 1. Input Validation
    if (!routeId || !pickupStop || !bookingDate || !bookingTime || !paymentMethodChosen) {
      return res.status(400).json({ message: 'Missing required booking fields.' });
    }

    if (paymentMethodChosen === 'mobile_money' && !phoneNumber) {
      return res.status(400).json({ message: 'Phone number is required for Mobile Money.' });
    }

    // 2. Fetch Route to calculate total fare server-side
    const route = await Route.findByPk(routeId);
    if (!route) {
      return res.status(404).json({ message: 'Route not found.' });
    }

    const passengerCount = Number(seatCount) || 1;
    const currency = isLocal ? 'UGX' : 'USD';
    const ratePerPerson = isLocal ? Number(route.fare) : Number(route.internationalFare);
    const totalFare = ratePerPerson * passengerCount;

    // 3. Determine payment provider (e.g., mtn_direct, airtel_direct, or pesapal)
    let routing = decideProvider({ paymentMethodChosen, phoneNumber, currency });
    
    // 4. Generate custom KSB ID and transaction reference string
    const customBookingId = generateKsbBookingId();
    const txRef = `booking-${customBookingId}`;

    // 5. Environment configuration fallback checks
    const isMomoConfigured = Boolean(process.env.MOMO_SUBSCRIPTION_KEY);
    const isAirtelConfigured = Boolean(
      process.env.AIRTEL_CLIENT_ID && process.env.AIRTEL_CLIENT_SECRET
    );

    if (routing.provider === 'mtn_direct' && !isMomoConfigured) {
      console.warn('⚠️ MTN MoMo credentials missing in environment. Falling back to Pesapal.');
      routing.provider = 'pesapal';
    }

    if (routing.provider === 'airtel_direct' && !isAirtelConfigured) {
      console.warn('⚠️ Airtel Money credentials missing in environment. Falling back to Pesapal.');
      routing.provider = 'pesapal';
    }

    // 6. Create initial Booking record in database
    const booking = await Booking.create({
      id: customBookingId,
      routeId,
      routeName: route.name,
      pickupStop,
      bookingDate,
      bookingTime,
      seatCount: passengerCount,
      isLocal,
      totalFare,
      currency,
      status: 'pending',
      paymentStatus: 'pending',
      paymentMethodChosen,
      provider: routing.provider,
      phoneNumber: routing.normalizedPhone,
      txRef,
      userId: req.user?.id,
    });

    // 7. Process Direct MTN MoMo (USSD Push Prompt)
    if (routing.provider === 'mtn_direct') {
      try {
        await momoService.requestToPay({
          txRef,
          amount: totalFare,
          phoneNumber: routing.normalizedPhone,
          payerMessage: `Payment for ${route.name}`,
        });

        return res.status(201).json({
          bookingId: booking.id,
          txRef,
          provider: 'mtn_direct',
          flow: 'ussd_push',
          totalFare,
          currency,
        });
      } catch (momoError) {
        console.error('⚠️ MTN Direct API failed. Falling back to Pesapal:', momoError.message);
        await booking.update({ provider: 'pesapal' });
        routing.provider = 'pesapal';
      }
    }

    // 8. Process Direct Airtel Money (USSD Push Prompt)
    if (routing.provider === 'airtel_direct') {
      try {
        throw new Error('Airtel Direct integration pending production credentials.');
      } catch (airtelError) {
        console.error('⚠️ Airtel Direct failed or unconfigured. Falling back to Pesapal:', airtelError.message);
        await booking.update({ provider: 'pesapal' });
        routing.provider = 'pesapal';
      }
    }

    // 9. Process Pesapal Payment (Card / Webview Flow)
    const customerEmail = email || req.user?.email || 'customer@busapp.com';

    const pesapalResponse = await pesapalService.submitOrder({
      txRef,
      amount: totalFare,
      currency,
      description: `Payment for ${route.name}`,
      email: customerEmail,
      phone: routing.normalizedPhone,
      firstName: req.user?.fullName?.split(' ')[0] || 'Rider',
      lastName: req.user?.fullName?.split(' ').slice(1).join(' ') || '',
    });

    console.log('📌 Pesapal Response Object:', pesapalResponse);

    // Save Pesapal order tracking ID to database record
    await booking.update({ providerTransactionId: pesapalResponse.order_tracking_id });

    return res.status(201).json({
      bookingId: booking.id,
      txRef,
      provider: 'pesapal',
      flow: 'webview',
      checkoutUrl: pesapalResponse.redirect_url,
      orderTrackingId: pesapalResponse.order_tracking_id,
      totalFare,
      currency,
    });

  } catch (error) {
    console.error('Payment initiation error:', error.response?.data || error.message);
    res.status(500).json({ message: 'Server error initiating payment.' });
  }
};

/**
 * Checks the real-time payment status from the gateway provider
 */
const getPaymentStatus = async (req, res) => {
  try {
    const { txRef } = req.params;
    const booking = await Booking.findOne({ where: { txRef } });

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found.' });
    }

    if (booking.paymentStatus !== 'pending') {
      return res.json({ status: booking.paymentStatus, booking });
    }

    if (booking.provider === 'mtn_direct') {
      const momoStatus = await momoService.getPaymentStatus(txRef);
      if (momoStatus.status === 'SUCCESSFUL') {
        await booking.update({
          paymentStatus: 'paid',
          status: 'confirmed',
          providerTransactionId: momoStatus.financialTransactionId,
        });
      } else if (momoStatus.status === 'FAILED') {
        await booking.update({ paymentStatus: 'failed', status: 'cancelled' });
      }
    } else if (booking.provider === 'pesapal') {
      const pesapalStatus = await pesapalService.getTransactionStatus(booking.providerTransactionId);
      if (pesapalStatus.payment_status_description === 'Completed') {
        await booking.update({ paymentStatus: 'paid', status: 'confirmed' });
      } else if (pesapalStatus.payment_status_description === 'Failed') {
        await booking.update({ paymentStatus: 'failed', status: 'cancelled' });
      }
    }

    res.json({ status: booking.paymentStatus, booking });
  } catch (error) {
    console.error('Status check error:', error.response?.data || error.message);
    res.status(500).json({ message: 'Server error checking payment status.' });
  }
};

/**
 * IPN Webhook endpoint for Pesapal backend-to-backend status updates
 */
const pesapalWebhook = async (req, res) => {
  try {
    const { OrderTrackingId } = req.query;
    const booking = await Booking.findOne({ where: { providerTransactionId: OrderTrackingId } });

    if (!booking) return res.status(404).send('Booking not found.');

    const status = await pesapalService.getTransactionStatus(OrderTrackingId);

    if (status.payment_status_description === 'Completed') {
      await booking.update({ paymentStatus: 'paid', status: 'confirmed' });
    } else if (status.payment_status_description === 'Failed') {
      await booking.update({ paymentStatus: 'failed', status: 'cancelled' });
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('PesaPal webhook error:', error.message);
    res.status(500).send('Error processing webhook.');
  }
};

/**
 * Handles GET redirect from Pesapal after completing payment in WebView
 */
const pesapalCallback = async (req, res) => {
  try {
    const { OrderTrackingId } = req.query;

    if (OrderTrackingId) {
      const status = await pesapalService.getTransactionStatus(OrderTrackingId);
      if (status.payment_status_description === 'Completed') {
        await Booking.update(
          { paymentStatus: 'paid', status: 'confirmed' },
          { where: { providerTransactionId: OrderTrackingId } }
        );
      }
    }

    res.send(`
      <html>
        <head><title>Payment Complete</title></head>
        <body style="display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;text-align:center;">
          <div>
            <h2 style="color:#2e7d32;">✅ Payment Completed!</h2>
            <p>Please wait, redirecting back to your application...</p>
          </div>
        </body>
      </html>
    `);
  } catch (error) {
    console.error('PesaPal callback error:', error.message);
    res.status(500).send('Error processing callback.');
  }
};

/**
 * Fetch all bookings across the entire app (Admin Dashboard)
 */
const getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      order: [['createdAt', 'DESC']],
    });
    res.json(bookings);
  } catch (error) {
    console.error('Error fetching all bookings:', error.message);
    res.status(500).json({ message: 'Server error fetching bookings.' });
  }
};

/**
 * Fetch bookings specifically for the currently logged-in mobile user
 */
const getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']],
    });
    res.json(bookings);
  } catch (error) {
    console.error('Error fetching user bookings:', error.message);
    res.status(500).json({ message: 'Server error fetching your bookings.' });
  }
};

/**
 * Admin status update for a booking
 */
const updateBookingStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, paymentStatus } = req.body;

    const booking = await Booking.findByPk(id);
    if (!booking) return res.status(404).json({ message: 'Booking not found.' });

    if (status) booking.status = status;
    if (paymentStatus) booking.paymentStatus = paymentStatus;
    await booking.save();

    res.json({ message: 'Booking updated successfully.', booking });
  } catch (error) {
    console.error('Error updating booking:', error.message);
    res.status(500).json({ message: 'Server error updating booking.' });
  }
};

/**
 * Mobile user cancellation of their own booking
 */
const cancelBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await Booking.findOne({ where: { id, userId: req.user.id } });

    if (!booking) return res.status(404).json({ message: 'Booking not found.' });

    booking.status = 'cancelled';
    await booking.save();

    res.json({ message: 'Booking cancelled successfully.', booking });
  } catch (error) {
    console.error('Error cancelling booking:', error.message);
    res.status(500).json({ message: 'Server error cancelling booking.' });
  }
};

module.exports = {
  initiatePayment,
  createBooking: initiatePayment, // Maps createBooking alias to initiatePayment
  getPaymentStatus,
  pesapalWebhook,
  pesapalCallback,
  getAllBookings,
  getMyBookings,
  updateBookingStatus,
  cancelBooking,
};