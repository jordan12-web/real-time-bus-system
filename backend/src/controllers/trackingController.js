import { reportLocation, getRecentLocations, trackingEmitter } from '../services/trackingService.js';

export const postReportLocation = async (req, res, next) => {
  try {
    const { tripId, latitude, longitude, speed_kmh, heading, recorded_at } = req.body;
    if (!tripId || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ error: 'tripId, latitude, and longitude are required' });
    }

    const lat = Number(latitude);
    const lng = Number(longitude);

    if (isNaN(lat) || lat < -90 || lat > 90) {
      return res.status(400).json({ error: 'latitude must be a number between -90 and 90' });
    }

    if (isNaN(lng) || lng < -180 || lng > 180) {
      return res.status(400).json({ error: 'longitude must be a number between -180 and 180' });
    }

    const location = await reportLocation({
      tripId,
      latitude: lat,
      longitude: lng,
      speed_kmh,
      heading,
      recorded_at
    });

    return res.status(201).json(location);
  } catch (error) {
    next(error);
  }
};

export const getTripRecentLocations = async (req, res, next) => {
  try {
    const { tripId } = req.params;
    const { limit } = req.query;
    const locations = await getRecentLocations({ tripId, limit });
    return res.status(200).json(locations);
  } catch (error) {
    next(error);
  }
};

export const streamTripLocations = (req, res) => {
  const { tripId } = req.params;

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  res.write(`data: ${JSON.stringify({ message: 'Connected to live tracking stream', tripId })}\n\n`);

  const onLocation = (location) => {
    res.write(`data: ${JSON.stringify(location)}\n\n`);
  };

  trackingEmitter.on(`location:${tripId}`, onLocation);

  req.on('close', () => {
    trackingEmitter.removeListener(`location:${tripId}`, onLocation);
  });
};
