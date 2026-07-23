const axios = require('axios');

const BASE_URL = process.env.PESAPAL_ENV === 'production'
  ? 'https://pay.pesapal.com/v3'
  : 'https://cybqa.pesapal.com/pesapalv3';

// Fetch fresh Bearer token
const getAccessToken = async () => {
  try {
    const response = await axios.post(
      `${BASE_URL}/api/Auth/RequestToken`,
      {
        consumer_key: process.env.PESAPAL_CONSUMER_KEY,
        consumer_secret: process.env.PESAPAL_CONSUMER_SECRET,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      }
    );
    return response.data.token;
  } catch (error) {
    console.error('❌ Pesapal Auth Error:', error.response?.data || error.message);
    throw new Error('Failed to authenticate with Pesapal.');
  }
};

// Register IPN URL dynamically if PESAPAL_NOTIFICATION_ID is not hardcoded in .env
const registerIpnUrl = async (token) => {
  const ipnUrl = process.env.PESAPAL_IPN_URL || 'https://your-render-app.onrender.com/api/payments/pesapal-webhook';
  
  try {
    const response = await axios.post(
      `${BASE_URL}/api/URLSetup/RegisterIPN`,
      {
        url: ipnUrl,
        ipn_notification_type: 'POST', // POST is recommended for v3 webhooks
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      }
    );
    console.log('✅ Auto-registered Pesapal IPN ID:', response.data.ipn_id);
    return response.data.ipn_id;
  } catch (error) {
    console.error('❌ Pesapal IPN Registration Error:', error.response?.data || error.message);
    throw new Error('Failed to register IPN with Pesapal.');
  }
};

const submitOrder = async ({ txRef, amount, currency, description, email, phone, firstName, lastName }) => {
  try {
    const token = await getAccessToken();

    // Use environment variable if set, otherwise auto-register IPN URL on the fly
    let notificationId = process.env.PESAPAL_NOTIFICATION_ID;
    if (!notificationId) {
      console.warn('⚠️ PESAPAL_NOTIFICATION_ID missing in env. Registering automatically...');
      notificationId = await registerIpnUrl(token);
    }

    const callbackUrl = process.env.PESAPAL_CALLBACK_URL || 'https://your-render-app.onrender.com/api/payments/pesapal-callback';

    const payload = {
      id: txRef,
      currency: currency || 'UGX',
      amount: Number(amount),
      description: description || 'Bus Ticket Booking',
      callback_url: callbackUrl,
      notification_id: notificationId,
      billing_address: {
        email_address: email || 'customer@busapp.com',
        phone_number: phone || '',
        first_name: firstName || 'Rider',
        last_name: lastName || '',
      },
    };

    const response = await axios.post(
      `${BASE_URL}/api/Transactions/SubmitOrderRequest`,
      payload,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      }
    );

    return response.data; // { order_tracking_id, redirect_url, status, error }
  } catch (error) {
    console.error('❌ Pesapal SubmitOrder Error:', error.response?.data || error.message);
    throw error;
  }
};

const getTransactionStatus = async (orderTrackingId) => {
  try {
    const token = await getAccessToken();
    const response = await axios.get(
      `${BASE_URL}/api/Transactions/GetTransactionStatus?orderTrackingId=${orderTrackingId}`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Accept': 'application/json',
        },
      }
    );
    return response.data;
  } catch (error) {
    console.error('❌ Pesapal GetTransactionStatus Error:', error.response?.data || error.message);
    throw error;
  }
};

module.exports = { submitOrder, getTransactionStatus, registerIpnUrl };