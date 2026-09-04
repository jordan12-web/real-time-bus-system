import axios from 'axios';
import axiosRetry from 'axios-retry';


let currentToken: string | null = null;

export function setAuthToken(token: string | null) {
  currentToken = token;
}

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'https://real-time-bus-system.onrender.com',
  timeout: 35000,
});


axiosRetry(apiClient, {
  retries: 3,
  retryDelay: axiosRetry.exponentialDelay,
  retryCondition: (error) => {
    return (
      axiosRetry.isNetworkError(error) ||
      axiosRetry.isRetryableError(error) ||
      error.code === 'ERR_NETWORK' ||
      error.code === 'ECONNABORTED'
    );
  },
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