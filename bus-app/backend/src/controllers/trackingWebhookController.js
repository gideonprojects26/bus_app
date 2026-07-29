const { Bus } = require('../models');

// Receives GPS updates pushed FROM TrackNav. The exact field names
// below (deviceId, lat, lng) are placeholders — update them to match
// TrackNav's actual payload once you have their docs. Everything else
// (lookup, update, security check) stays the same regardless of their
// exact field naming.
const receiveLocationUpdate = async (req, res) => {
  try {
    // SECURITY: verify this request actually came from TrackNav, not
    // a spoofed request. Replace this with whatever auth method
    // TrackNav actually provides (shared secret header, API key, etc.)
    const providedSecret = req.headers['x-tracknav-secret'];
    if (providedSecret !== process.env.TRACKNAV_WEBHOOK_SECRET) {
      return res.status(401).json({ message: 'Unauthorized webhook request.' });
    }

    const { deviceId, lat, lng, speed, timestamp } = req.body;

    if (!deviceId || lat === undefined || lng === undefined) {
      return res.status(400).json({ message: 'Missing required location fields.' });
    }

    const bus = await Bus.findOne({ where: { trackerDeviceId: deviceId } });

    if (!bus) {
      // Not necessarily an error — TrackNav might report devices we
      // haven't mapped to a bus yet. Log and acknowledge without
      // treating it as a failure.
      console.warn(`Received location for unmapped device: ${deviceId}`);
      return res.status(200).json({ message: 'Device not mapped to a bus, ignored.' });
    }

    await bus.update({
      currentLat: lat,
      currentLng: lng,
      lastLocationUpdate: timestamp ? new Date(timestamp) : new Date(),
    });

    res.status(200).json({ message: 'Location updated.' });
  } catch (error) {
    console.error('TrackNav webhook error:', error.message);
    res.status(500).json({ message: 'Server error processing location update.' });
  }
};

module.exports = { receiveLocationUpdate };