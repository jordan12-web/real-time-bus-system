import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createTrip } from '../api/tripsApi';
import type { CreateTripPayload } from '../types/trip';

export function useCreateTrip() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: CreateTripPayload) => createTrip(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trips'] });
    },
  });
}