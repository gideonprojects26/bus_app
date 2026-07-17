const axios = require('axios');

const BASE_URL = process.env.PESAPAL_ENV === 'production'
  ? 'https://pay.pesapal.com/v3'
  : 'https://cybqa.pesapal.com/pesapalv3';

// PesaPal tokens are short-lived; fetch fresh each time rather than
// caching, until the basic flow is proven working.
const getAccessToken = async () => {
  const response = await axios.post(`${BASE_URL}/api/Auth/RequestToken`, {
    consumer_key: process.env.PESAPAL_CONSUMER_KEY,
    consumer_secret: process.env.PESAPAL_CONSUMER_SECRET,
  });
  return response.data.token;
};

// Registers our IPN URL with PesaPal — required once before submitting
// orders, PesaPal needs to know where to send webhook notifications.
const registerIpnUrl = async (token) => {
  const response = await axios.post(
    `${BASE_URL}/api/URLSetup/RegisterIPN`,
    {
      url: process.env.PESAPAL_IPN_URL,
      ipn_notification_type: 'GET',
    },
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return response.data.ipn_id;
};

const submitOrder = async ({ txRef, amount, currency, description, email, phone, firstName, lastName }) => {
  const token = await getAccessToken();
  const ipnId = await registerIpnUrl(token);

  const response = await axios.post(
    `${BASE_URL}/api/Transactions/SubmitOrderRequest`,
    {
      id: txRef,
      currency,
      amount,
      description,
      callback_url: process.env.PESAPAL_CALLBACK_URL,
      notification_id: ipnId,
      billing_address: {
        email_address: email,
        phone_number: phone || '',
        first_name: firstName || 'Rider',
        last_name: lastName || '',
      },
    },
    { headers: { Authorization: `Bearer ${token}` } }
  );

  return response.data; // contains redirect_url and order_tracking_id
};

const getTransactionStatus = async (orderTrackingId) => {
  const token = await getAccessToken();
  const response = await axios.get(
    `${BASE_URL}/api/Transactions/GetTransactionStatus?orderTrackingId=${orderTrackingId}`,
    { headers: { Authorization: `Bearer ${token}` } }
  );
  return response.data; // contains payment_status_description, amount, etc.
};

module.exports = { submitOrder, getTransactionStatus };