import { apiClient } from './client';
import type { Trip, CreateTripPayload, TripBooking, TripStatus } from '../types/trip';

export async function listTrips(): Promise<Trip[]> {
  const response = await apiClient.get<Trip[]>('/trips');
  return response.data;
}

export async function createTrip(payload: CreateTripPayload): Promise<Trip> {
  const response = await apiClient.post<Trip>('/trips', payload);
  return response.data;
}

export async function getTrip(tripId: string): Promise<Trip> {
  const response = await apiClient.get<Trip>(`/trips/${tripId}`);
  return response.data;
}

export async function getTripBookings(tripId: string): Promise<TripBooking[]> {
  const response = await apiClient.get<TripBooking[]>(`/trips/${tripId}/bookings`);
  return response.data;
}

export async function updateTripStatus(tripId: string, status: TripStatus): Promise<Trip> {
  const response = await apiClient.patch<Trip>(`/trips/${tripId}/status`, { status });
  return response.data;
}