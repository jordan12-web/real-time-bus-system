import { useQuery } from '@tanstack/react-query';
import { listTrips } from '../api/tripsApi';

export function useTrips() {
  return useQuery({ queryKey: ['trips'], queryFn: listTrips });
}