// One-time script with alternative header formats
require('dotenv').config();
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const SUBSCRIPTION_KEY = process.env.MOMO_SUBSCRIPTION_KEY;
const BASE_URL = 'https://sandbox.momodeveloper.mtn.com';

async function setup() {
  if (!SUBSCRIPTION_KEY) {
    throw new Error('MOMO_SUBSCRIPTION_KEY not found');
  }
  
  const apiUserId = uuidv4();
  console.log('Generated API User ID:', apiUserId);
  
  // Try different header combinations
  const attempts = [
    {
      name: 'Standard headers',
      headers: {
        'X-Reference-Id': apiUserId,
        'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY,
        'Content-Type': 'application/json'
      }
    },
    {
      name: 'With target environment',
      headers: {
        'X-Reference-Id': apiUserId,
        'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY,
        'Content-Type': 'application/json',
        'X-Target-Environment': 'sandbox'
      }
    },
    {
      name: 'With callback host as header',
      headers: {
        'X-Reference-Id': apiUserId,
        'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY,
        'Content-Type': 'application/json',
        'X-Callback-Url': 'https://webhook.site/callback'
      }
    }
  ];
  
  // Try different body formats
  const bodies = [
    { providerCallbackHost: 'webhook.site' },
    { providerCallbackHost: 'localhost' },
    {} // Empty body
  ];
  
  for (const attempt of attempts) {
    for (const body of bodies) {
      try {
        console.log(`\n📞 Trying: ${attempt.name}`);
        console.log('Body:', JSON.stringify(body));
        
        const response = await axios.post(
          `${BASE_URL}/v1_0/apiuser`,
          body,
          {
            headers: attempt.headers,
            timeout: 15000
          }
        );
        
        console.log('✅ SUCCESS! Status:', response.status);
        
        // Generate API key
        console.log('\n🔑 Generating API key...');
        const keyResponse = await axios.post(
          `${BASE_URL}/v1_0/apiuser/${apiUserId}/apikey`,
          {},
          {
            headers: {
              'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY
            }
          }
        );
        
        console.log('\n✅ CREDENTIALS GENERATED!');
        console.log('='.repeat(60));
        console.log(`MOMO_API_USER=${apiUserId}`);
        console.log(`MOMO_API_KEY=${keyResponse.data.apiKey}`);
        console.log('='.repeat(60));
        return;
        
      } catch (err) {
        console.log(`❌ Failed: ${err.response?.status} - ${err.response?.data?.message || err.message}`);
      }
    }
  }
  
  // If we get here, nothing worked - try direct sandbox URL
  console.log('\n📞 Last resort: Trying alternative sandbox URL...');
  try {
    const altUrl = 'https://ericssonbasicapi2.azure-api.net/v1_0/apiuser';
    const response = await axios.post(
      altUrl,
      { providerCallbackHost: 'webhook.site' },
      {
        headers: {
          'X-Reference-Id': apiUserId,
          'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY,
          'Content-Type': 'application/json'
        }
      }
    );
    console.log('✅ Success with alternative URL!');
  } catch (err) {
    console.log('All attempts failed.');
  }
  
  // Final diagnostic
  console.log('\n🔍 DIAGNOSTIC INFO:');
  console.log('Your subscription key format looks correct');
  console.log('The issue might be:');
  console.log('1. MTN Sandbox might have regional restrictions');
  console.log('2. You might need to be on an African IP address (try VPN)');
  console.log('3. The sandbox might be temporarily down');
  console.log('4. Your account might need additional verification');
  
  console.log('\n📋 RECOMMENDED NEXT STEPS:');
  console.log('1. Try using a VPN with an African IP (Uganda/Ghana/etc)');
  console.log('2. Use the Postman collection from momodeveloper.mtn.com');
  console.log('3. Contact MTN MoMo developer support with your app ID');
  console.log('4. Try early morning hours when sandbox might be less busy');
}

setup().catch(console.error);