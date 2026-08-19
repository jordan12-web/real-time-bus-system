import Trip from '../models/Trip.js';

export const createTrip = async ({
  route_id,
  origin = 'Addis Ababa',
  destination = 'Hawassa',
  vehicle_id,
  driver_id,
  departure_time,
  arrival_time,
  price_per_seat
}) => {
  const trip = await Trip.create({
    route_id,
    origin,
    destination,
    vehicle_id,
    driver_id,
    departure_time: new Date(departure_time),
    arrival_time: new Date(arrival_time),
    price_per_seat
  });
  return trip.toJSON();
};

export const getAllTrips = async (filter = {}) => {
  const query = {};
  if (filter.origin) {
    query.origin = { $regex: filter.origin, $options: 'i' };
  }
  if (filter.destination) {
    query.destination = { $regex: filter.destination, $options: 'i' };
  }
  if (filter.time) {
    query.departure_time = { $gte: new Date(filter.time) };
  }

  const trips = await Trip.find(query).sort({ departure_time: 1 });
  return trips.map((t) => t.toJSON());
};

export const getTripById = async (id) => {
  const trip = await Trip.findById(id);
  if (!trip) {
    const error = new Error('Trip not found');
    error.statusCode = 404;
    throw error;
  }
  return trip.toJSON();
};
