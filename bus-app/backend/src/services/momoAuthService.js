const axios = require('axios');

const BASE_URL = 'https://sandbox.momodeveloper.mtn.com';

// Fetches a fresh Bearer token using Basic Auth (API User + API Key),
// required before any /requesttopay call. Tokens expire after roughly
// an hour, so this should be called fresh for each payment attempt
// rather than cached long-term for now (we'll optimize with caching
// once the basic flow works end-to-end).
const getAccessToken = async () => {
  const credentials = Buffer.from(
    `${process.env.MOMO_API_USER}:${process.env.MOMO_API_KEY}`
  ).toString('base64');

  const response = await axios.post(
    `${BASE_URL}/collection/token/`,
    {},
    {
      headers: {
        Authorization: `Basic ${credentials}`,
        'Ocp-Apim-Subscription-Key': process.env.MOMO_SUBSCRIPTION_KEY,
      },
    }
  );

  return response.data.access_token;
};

module.exports = { getAccessToken };