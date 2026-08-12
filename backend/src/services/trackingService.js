import EventEmitter from 'events';
import TripLocation from '../models/TripLocation.js';
import Trip from '../models/Trip.js';

export const trackingEmitter = new EventEmitter();

export const reportLocation = async ({ tripId, latitude, longitude, speed_kmh, heading, recorded_at }) => {
  const trip = await Trip.findById(tripId);
  if (!trip) {
    const error = new Error('Trip not found');
    error.statusCode = 404;
    throw error;
  }

  const location = await TripLocation.create({
    trip_id: trip._id,
    latitude,
    longitude,
    speed_kmh: speed_kmh || 0,
    heading: heading || 0,
    recorded_at: recorded_at ? new Date(recorded_at) : new Date()
  });

  const locationJSON = location.toJSON();
  trackingEmitter.emit(`location:${tripId}`, locationJSON);

  return locationJSON;
};

export const getRecentLocations = async ({ tripId, limit = 50 }) => {
  const trip = await Trip.findById(tripId);
  if (!trip) {
    const error = new Error('Trip not found');
    error.statusCode = 404;
    throw error;
  }

  const limitNumber = Math.min(parseInt(limit, 10) || 50, 200);
  const locations = await TripLocation.find({ trip_id: tripId })
    .sort({ recorded_at: -1 })
    .limit(limitNumber);

  return locations.map((loc) => loc.toJSON());
};
