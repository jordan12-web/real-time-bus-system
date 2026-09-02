import { useMutation, useQueryClient } from '@tanstack/react-query';
import { updateTripStatus } from '../api/tripsApi';
import type { TripStatus } from '../types/trip';

export function useUpdateTripStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ tripId, status }: { tripId: string; status: TripStatus }) =>
      updateTripStatus(tripId, status),
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ['trips'] });
      queryClient.invalidateQueries({ queryKey: ['trips', variables.tripId] });
    },
  });
}