import { useQuery } from '@tanstack/react-query';
import { listPayments } from '../api/paymentsApi';

export function usePayments() {
  return useQuery({ queryKey: ['payments'], queryFn: listPayments });
}