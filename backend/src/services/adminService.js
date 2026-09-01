import Trip from '../models/Trip.js';
import Booking from '../models/Booking.js';
import Payment from '../models/Payment.js';

export const getAdminStats = async () => {
  const [tripCount, bookingCount, revenueResult] = await Promise.all([
    Trip.countDocuments(),
    Booking.countDocuments(),
    Payment.aggregate([
      { $match: { status: 'success' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ])
  ]);

  return {
    tripCount,
    bookingCount,
    totalRevenue: revenueResult[0]?.total ?? 0,
    // Every Payment defaults to ETB and nothing in this system currently
    // supports multi-currency — hardcoding is accurate today, not a guess.
    currency: 'ETB'
  };
};