import axios from 'axios';


let currentToken: string | null = null;

export function setAuthToken(token: string | null) {
  currentToken = token;
}

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'https://real-time-bus-system.onrender.com',
  timeout: 15000,
});

apiClient.interceptors.request.use((config) => {
  if (currentToken) {
    config.headers.Authorization = `Bearer ${currentToken}`;
  }
  return config;
});

export interface ApiErrorBody {
  error?: string;
}

export function extractErrorMessage(error: unknown): string {
  if (axios.isAxiosError<ApiErrorBody>(error)) {
    return error.response?.data?.error ?? error.message;
  }
  return 'Something went wrong.';
}
