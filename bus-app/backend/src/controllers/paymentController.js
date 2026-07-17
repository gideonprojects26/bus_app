const { Booking, Route } = require('../models');
const { v4: uuidv4 } = require('uuid');
const { decideProvider } = require('../services/providerRouter');
const pesapalService = require('../services/pesapalService');
const momoService = require('../services/momoService');

const initiatePayment = async (req, res) => {
  try {
    const {
      routeId, pickupStop, bookingDate, bookingTime,
      seatCount, isLocal, paymentMethodChosen, phoneNumber, email,
    } = req.body;

    if (!routeId || !pickupStop || !bookingDate || !bookingTime || !paymentMethodChosen) {
      return res.status(400).json({ message: 'Missing required booking fields.' });
    }

    if (paymentMethodChosen === 'mobile_money' && !phoneNumber) {
      return res.status(400).json({ message: 'Phone number is required for Mobile Money.' });
    }

    // SECURITY: fare is computed here, from the Route record itself —
    // never taken from req.body. This is the fix for the "never trust
    // the client" gap: no request can alter the price it's charged.
    const route = await Route.findByPk(routeId);
    if (!route) {
      return res.status(404).json({ message: 'Route not found.' });
    }

    const passengerCount = Number(seatCount) || 1;
    const currency = isLocal ? 'UGX' : 'USD';
    const ratePerPerson = isLocal ? Number(route.fare) : Number(route.internationalFare);
    const totalFare = ratePerPerson * passengerCount;

    const routing = decideProvider({ paymentMethodChosen, phoneNumber, currency });
    const txRef = `booking-${uuidv4()}`;

    const booking = await Booking.create({
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
      userId: req.user.id,
    });

    if (routing.provider === 'mtn_direct') {
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
    }

    if (routing.provider === 'airtel_direct') {
      return res.status(501).json({ message: 'Airtel Direct not yet implemented.' });
    }

    const pesapalResponse = await pesapalService.submitOrder({
      txRef,
      amount: totalFare,
      currency,
      description: `Payment for ${route.name}`,
      email,
      phone: routing.normalizedPhone,
      firstName: req.user.fullName?.split(' ')[0] || 'Rider',
      lastName: req.user.fullName?.split(' ').slice(1).join(' ') || '',
    });

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

module.exports = { initiatePayment, getPaymentStatus, pesapalWebhook };