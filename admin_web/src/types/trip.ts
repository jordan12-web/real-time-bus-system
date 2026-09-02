export type TripStatus = 'scheduled' | 'in_transit' | 'completed' | 'cancelled';

/** Matches backend/src/models/Trip.js exactly. */
export interface Trip {
  id: string;
  route_id: string;
  origin: string;
  destination: string;
  vehicle_id: string;
  driver_id: string;
  departure_time: string;
  arrival_time: string;
  price_per_seat: number;
  status: TripStatus;
}

export interface CreateTripPayload {
  route_id: string;
  vehicle_id: string;
  driver_id: string;
  origin: string;
  destination: string;
  departure_time: string;
  arrival_time: string;
  price_per_seat: number;
}

export type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'expired';

export type TicketStatus = 'issued' | 'used' | 'revoked';

export interface TripBooking {
  id: string;
  user_id: string;
  trip_id: string;
  seat_number: string | null;
  status: BookingStatus;
  total_amount: number;
  currency: string;
  created_at: string;
  passenger?: {
    id: string;
    full_name: string;
    email: string;
  };
  ticket?: {
    id: string;
    status: TicketStatus;
  };
}