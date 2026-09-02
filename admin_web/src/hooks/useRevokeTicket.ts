import { useMutation, useQueryClient } from '@tanstack/react-query';
import { revokeTicket } from '../api/ticketsApi';

export function useRevokeTicket(tripId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (ticketId: string) => revokeTicket(ticketId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['trips', tripId, 'bookings'] });
    },
  });
}