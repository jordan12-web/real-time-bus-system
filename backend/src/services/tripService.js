import Trip from '../models/Trip.js';
import Booking from '../models/Booking.js';
import Ticket from '../models/Ticket.js';

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

// Manifest for one trip — who's booked, seat, payment status. Populates
// user_id so the admin dashboard can show a passenger name/email without a
// second round trip per row. Reshaped explicitly rather than relying on
// Mongoose's populate+toJSON subdocument-transform interaction (that
// behavior is inconsistent across Mongoose versions) — user_id stays a
// plain string ID, matching every other booking response's shape, with a
// separate `passenger` object added alongside it.
export const getBookingsForTrip = async (tripId) => {
  // Confirm the trip exists first so a bad ID gives a clear 404 rather
  // than a silent empty list.
  await getTripById(tripId);

  const bookings = await Booking.find({ trip_id: tripId })
    .populate('user_id', 'full_name email')
    .sort({ created_at: -1 });

  // One query for all tickets on this trip's bookings, rather than N+1 —
  // ticket.booking_id is unique, so this is a straightforward id -> ticket map.
  const bookingIds = bookings.map((b) => b._id);
  const tickets = await Ticket.find({ booking_id: { $in: bookingIds } });
  const ticketByBookingId = new Map(tickets.map((t) => [t.booking_id.toString(), t]));

  return bookings.map((b) => {
    const json = b.toJSON();
    const populatedUser = json.user_id;
    if (populatedUser && typeof populatedUser === 'object') {
      json.passenger = {
        id: (populatedUser._id ?? populatedUser.id)?.toString(),
        full_name: populatedUser.full_name,
        email: populatedUser.email
      };
      json.user_id = json.passenger.id;
    }
    const ticket = ticketByBookingId.get(b._id.toString());
    if (ticket) {
      json.ticket = { id: ticket._id.toString(), status: ticket.status };
    }
    return json;
  });
};

const TRIP_STATUSES = ['scheduled', 'in_transit', 'completed', 'cancelled'];

export const updateTripStatus = async (id, newStatus) => {
  if (!TRIP_STATUSES.includes(newStatus)) {
    const error = new Error(`status must be one of: ${TRIP_STATUSES.join(', ')}`);
    error.statusCode = 400;
    throw error;
  }

  const trip = await Trip.findById(id);
  if (!trip) {
    const error = new Error('Trip not found');
    error.statusCode = 404;
    throw error;
  }

  trip.status = newStatus;
  await trip.save();
  return trip.toJSON();
};