const axios = require('axios');
const { getAccessToken } = require('./momoAuthService');

const BASE_URL = 'https://sandbox.momodeveloper.mtn.com';

// Sends the USSD push request — this is what triggers the PIN prompt
// on the customer's phone. externalId is our own reference (the txRef).
const requestToPay = async ({ txRef, amount, phoneNumber, payerMessage }) => {
  const token = await getAccessToken();

  await axios.post(
    `${BASE_URL}/collection/v1_0/requesttopay`,
    {
      amount: String(amount),
      currency: 'EUR', // MTN sandbox ONLY supports EUR for testing; production uses UGX
      externalId: txRef,
      payer: {
        partyIdType: 'MSISDN',
        partyId: phoneNumber,
      },
      payerMessage: payerMessage || 'Bus Tours booking payment',
      payeeNote: 'Booking payment',
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'X-Reference-Id': txRef,
        'X-Target-Environment': 'sandbox',
        'Ocp-Apim-Subscription-Key': process.env.MOMO_SUBSCRIPTION_KEY,
        'Content-Type': 'application/json',
      },
    }
  );

  return { txRef }; // MTN returns 202 Accepted with empty body; status is checked separately
};

const getPaymentStatus = async (txRef) => {
  const token = await getAccessToken();

  const response = await axios.get(
    `${BASE_URL}/collection/v1_0/requesttopay/${txRef}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'X-Target-Environment': 'sandbox',
        'Ocp-Apim-Subscription-Key': process.env.MOMO_SUBSCRIPTION_KEY,
      },
    }
  );

  return response.data; // status: 'PENDING' | 'SUCCESSFUL' | 'FAILED'
};

module.exports = { requestToPay, getPaymentStatus };