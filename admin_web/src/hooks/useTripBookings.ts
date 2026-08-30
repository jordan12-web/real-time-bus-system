import { useQuery } from '@tanstack/react-query';
import { getTrip, getTripBookings } from '../api/tripsApi';

export function useTrip(tripId: string | undefined) {
  return useQuery({
    queryKey: ['trips', tripId],
    queryFn: () => getTrip(tripId!),
    enabled: !!tripId,
  });
}

export function useTripBookings(tripId: string | undefined) {
  return useQuery({
    queryKey: ['trips', tripId, 'bookings'],
    queryFn: () => getTripBookings(tripId!),
    enabled: !!tripId,
  });
}