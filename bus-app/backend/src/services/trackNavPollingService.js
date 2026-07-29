const cron = require('node-cron');
const axios = require('axios');
const { Bus } = require('../models');

// Runs every 15 seconds, pulling current positions from TrackNav's
// API as a fallback if webhooks aren't available or are unreliable.
// PLACEHOLDER: update the URL, auth, and response field names once
// TrackNav's actual API docs are available.
const startPolling = () => {
  cron.schedule('*/15 * * * * *', async () => {
    try {
      const response = await axios.get('https://api.tracknav.example.com/v1/devices/positions', {
        headers: { Authorization: `Bearer ${process.env.TRACKNAV_API_KEY}` },
      });

      for (const device of response.data.devices) {
        const bus = await Bus.findOne({ where: { trackerDeviceId: device.id } });
        if (bus) {
          await bus.update({
            currentLat: device.lat,
            currentLng: device.lng,
            lastLocationUpdate: new Date(),
          });
        }
      }
    } catch (error) {
      console.error('TrackNav polling error:', error.message);
    }
  });
};

module.exports = { startPolling };