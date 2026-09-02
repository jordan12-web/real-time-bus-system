export type PaymentStatus = 'pending' | 'success' | 'failed';

/** Matches GET /payments (admin-only list) — the `booking` object is added
 * server-side (see backend/src/services/paymentService.js:listAllPayments),
 * same reshape pattern as TripBooking.passenger. */
export interface Payment {
  id: string;
  booking_id: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  chapa_tx_ref: string;
  created_at: string;
  booking?: {
    id: string;
    trip_id: string;
    user_id: string;
    seat_number: string | null;
  };
}