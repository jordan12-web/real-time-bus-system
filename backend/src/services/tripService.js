import Trip from '../models/Trip.js';

export const createTrip = async ({
  route_id,
  vehicle_id,
  driver_id,
  departure_time,
  arrival_time,
  price_per_seat
}) => {
  const trip = await Trip.create({
    route_id,
    vehicle_id,
    driver_id,
    departure_time: new Date(departure_time),
    arrival_time: new Date(arrival_time),
    price_per_seat
  });
  return trip.toJSON();
};

export const getAllTrips = async () => {
  const trips = await Trip.find().sort({ departure_time: 1 });
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
