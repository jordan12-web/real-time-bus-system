import { reportLocation, getRecentLocations, trackingEmitter } from '../services/trackingService.js';

export const postReportLocation = async (req, res, next) => {
  try {
    const { tripId, latitude, longitude, speed_kmh, heading, recorded_at } = req.body;
    if (!tripId || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ error: 'tripId, latitude, and longitude are required' });
    }

    const location = await reportLocation({
      tripId,
      latitude,
      longitude,
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
