import { useQuery } from '@tanstack/react-query';
import { getStats } from '../api/statsApi';

export function useStats() {
  return useQuery({ queryKey: ['admin', 'stats'], queryFn: getStats });
}