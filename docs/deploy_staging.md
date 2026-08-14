# Staging Deployment & Webhook Integration Guide (Render)

This guide provides step-by-step instructions to deploy the Real-Time Bus Reservation System backend to **Render** staging environment, expose webhooks publicly, and configure Chapa sandbox webhooks.

---

## 1. Provider Choice: Render
Render provides free/low-cost Web Service hosting with automatic HTTPS, continuous deployment from GitHub, and environment variable management suitable for Node.js Express APIs.

---

## 2. Step-by-Step Staging Deployment

### Step 1: Push Repository to GitHub
Ensure all code and scaffold files are pushed to your remote GitHub repository branch (`develop` or `main`).

### Step 2: Create Web Service on Render
1. Log in to [Render Dashboard](https://dashboard.render.com/).
2. Click **New +** → **Web Service**.
3. Connect your GitHub repository (`real-time-bus-system`).
4. Configure service settings:
   - **Name**: `bus-system-backend-staging`
   - **Region**: Oregon (US West) or Frankfurt (EU Central)
   - **Branch**: `develop` or `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Instance Type**: Free or Starter

---

## 3. Staging Environment Variables

Under the **Environment** tab on Render, add the following environment variables:

| Key | Example / Staging Value | Note |
| :--- | :--- | :--- |
| `NODE_ENV` | `staging` | Sets Node environment |
| `PORT` | `10000` | Render default port |
| `MONGODB_URI` | `mongodb+srv://user:pass@cluster.mongodb.net/bus_system_staging` | MongoDB Atlas staging database |
| `JWT_SECRET` | `staging_jwt_access_secret_key_987654321` | Access token secret |
| `JWT_REFRESH_SECRET` | `staging_jwt_refresh_secret_key_123456789` | Refresh token secret |
| `CHAPA_SECRET_KEY` | `CHASECK_TEST-xxxxxxxxxxxxxxxxxxxx` | Chapa sandbox secret key |
| `CHAPA_PUBLIC_KEY` | `CHAPUB_TEST-xxxxxxxxxxxxxxxxxxxx` | Chapa sandbox public key |
| `SENTRY_DSN` | `https://xxxx@o0.ingest.sentry.io/0` | Optional Sentry monitoring DSN |

---

## 4. Public Webhook Exposure & Chapa Sandbox Configuration

### Local Testing with Ngrok
To receive Chapa webhooks during local development:

1. Start your backend locally on port 3000:
   ```bash
   cd backend && npm run dev
   ```
2. Start ngrok tunnel:
   ```bash
   ngrok http 3000
   ```
3. Copy the generated HTTPS URL (e.g. `https://a1b2c3.ngrok-free.app`).
4. Webhook URL: `https://a1b2c3.ngrok-free.app/payments/webhook`

### Staging Public Webhook URL
On Render, your public webhook endpoint will be:
`https://bus-system-backend-staging.onrender.com/payments/webhook`

### Configuring Chapa Sandbox Webhook
1. Log in to the [Chapa Dashboard](https://dashboard.chapa.co/).
2. Navigate to **Settings** → **API & Webhook**.
3. Set **Webhook URL** to:
   `https://bus-system-backend-staging.onrender.com/payments/webhook`
4. Save settings.

---

## 5. Health Check & Staging Verification Commands

Once deployed, verify the staging service status:

### Health Check
```bash
curl -i https://bus-system-backend-staging.onrender.com/health
```
**Expected Response**: `HTTP/1.1 200 OK` → `{"status":"OK"}`

### Public Webhook Verification
```bash
curl -X POST https://bus-system-backend-staging.onrender.com/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": "charge.success",
    "tx_ref": "tx-test-12345",
    "status": "success"
  }'
```
