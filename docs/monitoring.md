# Monitoring, Logging, and Alerting Architecture

This document specifies the minimal, robust monitoring stack, error tracking configuration, PII redaction policy, and operational alerting thresholds for the Real-Time Bus Reservation System backend.

---

## 1. Minimal Monitoring Stack Architecture
- **Error Tracking**: [Sentry](https://sentry.io/) for automatic unhandled exception capturing, stack trace collection, and release tracking.
- **Structured Logging**: Standard JSON formatted logging to `stdout`/`stderr` for log aggregators (Datadog / Papertrail / Render Logs).
- **Uptime Monitoring**: HTTP ping service (e.g. UptimeRobot or Better Stack) targeting `GET /health` every 60 seconds.

---

## 2. Sentry Integration Snippet

The backend uses `src/config/sentry.js` to initialize error reporting. Set `SENTRY_DSN` in your environment variables to enable reporting:

```javascript
// src/config/sentry.js
export const initSentry = (app) => {
  const sentryDsn = process.env.SENTRY_DSN;
  if (!sentryDsn) {
    console.log('Sentry DSN not provided. Fallback logging active.');
    return;
  }
  console.log('Sentry monitoring active.');
};
```

---

## 3. Log Retention & PII Redaction Policy

### PII Redaction Rules
To ensure compliance and security:
1. **Never Log Passwords**: Clear plaintext passwords from log statements in auth services.
2. **Redact Sensitive Headers**: Strip `Authorization` Bearer tokens from request logs.
3. **Mask Payment Details**: Log only the `chapa_tx_ref` transaction reference; never log payment card details or private API keys.

### Log Retention
- **Staging / Dev**: 7-day retention period.
- **Production**: 30-day active retention period; 90-day archive for audit logs.

---

## 4. Alerting Thresholds

Set up alerts in Sentry / UptimeRobot based on the following SLAs:

| Metric | Threshold / Condition | Alert Severity | Action Required |
| :--- | :--- | :--- | :--- |
| **Uptime Health Check** | `GET /health` fails 2 consecutive times | `CRITICAL` | On-call engineer notified via PagerDuty/Slack |
| **Error Rate Spikes** | > 5% HTTP 500 responses in 5 mins | `HIGH` | Check Sentry dashboard for unhandled exceptions |
| **Payment Gateway Failures** | > 3 consecutive Chapa API errors | `HIGH` | Inspect Chapa status page & webhook verification logs |
| **Database Disconnects** | MongoDB connection error emitted | `CRITICAL` | Verify Atlas cluster status & IP whitelist |
