import { createTrip, getAllTrips, getTripById } from '../services/tripService.js';

export const postTrip = async (req, res, next) => {
  try {
    const { route_id, vehicle_id, driver_id, departure_time, arrival_time, price_per_seat } = req.body;

    if (!route_id || !vehicle_id || !driver_id || !departure_time || !arrival_time || price_per_seat === undefined) {
      return res.status(400).json({ error: 'Missing required trip fields' });
    }

    const trip = await createTrip({
      route_id,
      vehicle_id,
      driver_id,
      departure_time,
      arrival_time,
      price_per_seat
    });

    return res.status(201).json(trip);
  } catch (error) {
    next(error);
  }
};

export const getTrips = async (req, res, next) => {
  try {
    const trips = await getAllTrips();
    return res.status(200).json(trips);
  } catch (error) {
    next(error);
  }
};

export const getTrip = async (req, res, next) => {
  try {
    const trip = await getTripById(req.params.id);
    return res.status(200).json(trip);
  } catch (error) {
    next(error);
  }
};
