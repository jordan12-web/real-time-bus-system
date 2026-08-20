import {
  createBooking,
  getBookingById,
  cancelBooking,
  listBookingsForUser,
} from "../services/bookingService.js";

export const postBooking = async (req, res, next) => {
  try {
    const { trip_id, seat_number } = req.body;
    if (!trip_id) {
      return res.status(400).json({ error: "trip_id is required" });
    }

    const booking = await createBooking({
      user_id: req.user.id,
      trip_id,
      seat_number,
    });
    return res.status(201).json(booking);
  } catch (error) {
    next(error);
  }
};

export const getMyBookings = async (req, res, next) => {
  try {
    const bookings = await listBookingsForUser(req.user.id);
    return res.status(200).json(bookings);
  } catch (error) {
    next(error);
  }
};

export const getBooking = async (req, res, next) => {
  try {
    const booking = await getBookingById(
      req.params.id,
      req.user.id,
      req.user.role,
    );
    return res.status(200).json(booking);
  } catch (error) {
    next(error);
  }
};

export const deleteBooking = async (req, res, next) => {
  try {
    const booking = await cancelBooking(
      req.params.id,
      req.user.id,
      req.user.role,
    );
    return res.status(200).json(booking);
  } catch (error) {
    next(error);
  }
};
