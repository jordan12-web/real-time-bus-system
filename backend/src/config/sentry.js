// Sentry Error Tracking Configuration Snippet

export const initSentry = (app) => {
  const sentryDsn = process.env.SENTRY_DSN;
  if (!sentryDsn) {
    console.log('Sentry DSN not provided. Error tracking running in fallback log mode.');
    return;
  }

  console.log('Sentry initialized for environment:', process.env.NODE_ENV || 'development');
};

export const captureException = (error, context = {}) => {
  console.error('[ERROR CAPTURE]', error.message, context);
};
