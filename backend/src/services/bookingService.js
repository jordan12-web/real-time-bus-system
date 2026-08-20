import Booking from '../models/Booking.js';
import Trip from '../models/Trip.js';

export const createBooking = async ({ user_id, trip_id, seat_number }) => {
  const trip = await Trip.findById(trip_id);
  if (!trip) {
    const error = new Error('Trip not found');
    error.statusCode = 404;
    throw error;
  }

  if (trip.status === 'cancelled' || trip.status === 'completed') {
    const error = new Error('Cannot book a trip that is completed or cancelled');
    error.statusCode = 400;
    throw error;
  }

  const existingUserBooking = await Booking.findOne({
    user_id,
    trip_id,
    status: { $in: ['pending', 'confirmed'] }
  });

  if (existingUserBooking) {
    const error = new Error('You already have an active booking for this trip');
    error.statusCode = 400;
    throw error;
  }

  if (seat_number) {
    const existingSeatBooking = await Booking.findOne({
      trip_id,
      seat_number,
      status: { $in: ['pending', 'confirmed'] }
    });

    if (existingSeatBooking) {
      const error = new Error(`Seat ${seat_number} is already reserved for this trip`);
      error.statusCode = 400;
      throw error;
    }
  }

  const booking = await Booking.create({
    user_id,
    trip_id,
    seat_number: seat_number || null,
    total_amount: trip.price_per_seat,
    currency: 'ETB',
    status: 'pending',
    hold_expires_at: new Date(Date.now() + 15 * 60 * 1000)
  });

  return booking.toJSON();
};

export const getBookingById = async (id, userId, role) => {
  const booking = await Booking.findById(id);
  if (!booking) {
    const error = new Error('Booking not found');
    error.statusCode = 404;
    throw error;
  }

  if (role !== 'admin' && role !== 'driver' && booking.user_id.toString() !== userId) {
    const error = new Error('Forbidden: Access denied to this booking');
    error.statusCode = 403;
    throw error;
  }

  return booking.toJSON();
};

export const cancelBooking = async (id, userId, role) => {
  const booking = await Booking.findById(id);
  if (!booking) {
    const error = new Error('Booking not found');
    error.statusCode = 404;
    throw error;
  }

  if (role !== 'admin' && role !== 'driver' && booking.user_id.toString() !== userId) {
    const error = new Error('Forbidden: Access denied to cancel this booking');
    error.statusCode = 403;
    throw error;
  }

  if (booking.status === 'cancelled') {
    const error = new Error('Booking is already cancelled');
    error.statusCode = 400;
    throw error;
  }

  booking.status = 'cancelled';
  await booking.save();

  return booking.toJSON();
};

export const listBookingsForUser = async (userId) => {
  const bookings = await Booking.find({ user_id: userId }).sort({ created_at: -1 });
  return bookings.map((booking) => booking.toJSON());
};