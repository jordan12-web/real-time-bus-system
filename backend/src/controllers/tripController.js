import { createTrip, getAllTrips, getTripById } from '../services/tripService.js';

export const postTrip = async (req, res, next) => {
  try {
    const { route_id, vehicle_id, driver_id, departure_time, arrival_time, price_per_seat } = req.body;

    if (!route_id || !vehicle_id || !driver_id || !departure_time || !arrival_time || price_per_seat === undefined) {
      return res.status(400).json({ error: 'Missing required fields: route_id, vehicle_id, driver_id, departure_time, arrival_time, price_per_seat' });
    }

    const depDate = new Date(departure_time);
    const arrDate = new Date(arrival_time);
    if (isNaN(depDate.getTime()) || isNaN(arrDate.getTime())) {
      return res.status(400).json({ error: 'departure_time and arrival_time must be valid date strings' });
    }

    if (depDate >= arrDate) {
      return res.status(400).json({ error: 'departure_time must be before arrival_time' });
    }

    if (typeof price_per_seat !== 'number' || price_per_seat <= 0) {
      return res.status(400).json({ error: 'price_per_seat must be a positive number' });
    }

    const trip = await createTrip({
      route_id: route_id.trim(),
      vehicle_id: vehicle_id.trim(),
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
