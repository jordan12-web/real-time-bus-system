# Real-Time Bus Reservation System — API Runbook & Testing Guide

This guide provides operational instructions for running the backend locally, executing API test suites via Postman and Newman, simulating Chapa payment webhooks, and managing secrets.

---

## 1. Local Setup & Running the Backend

### Prerequisites
- Node.js v22+
- MongoDB Atlas cluster URI or local MongoDB instance

### Step 1: Environment Configuration
Create a `.env` file inside the `backend/` folder based on `.env.example`:

```env
PORT=3000
MONGODB_URI=mongodb+srv://yordanosmolla12:bus-system-password@cluster0.yx969hg.mongodb.net/bus_system
JWT_SECRET=your_secure_jwt_access_secret_key
JWT_REFRESH_SECRET=your_secure_jwt_refresh_secret_key
CHAPA_SECRET_KEY=CHASECK_TEST-replace_with_your_chapa_secret_key
CHAPA_PUBLIC_KEY=CHAPUB_TEST-replace_with_your_chapa_public_key
```

### Step 2: Install Dependencies & Start Server
Navigate to the `backend/` directory:

```bash
cd backend
npm install
npm run dev
```

The server will connect to MongoDB and start listening on `http://localhost:3000`. Verify by visiting `http://localhost:3000/health`.

---

## 2. Running Postman Collection & Environment

1. Open Postman.
2. Click **Import** and select:
   - `docs/postman_collection.json`
   - `docs/postman_environment.json`
3. Set **Bus System Local Environment** as the active environment.
4. Execute `Auth > Signup Passenger` or `Auth > Login Passenger`.
5. Copy the returned `accessToken` and `refreshToken` into the environment variables.

---

## 3. Simulating Chapa Payment Webhooks

Chapa sends a JSON payload to `/payments/webhook` upon payment completion. The backend verifies the transaction via Chapa's official API (`GET /v1/transaction/verify/:tx_ref`) using `CHAPA_SECRET_KEY` before confirming the booking.

### Example Webhook Simulation Command (cURL):

```bash
curl -X POST http://localhost:3000/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": "charge.success",
    "tx_ref": "tx-64f1a2b3c4d5e6f7a8b9c0d3-1770651500000",
    "status": "success"
  }'
```

---

## 4. Running Automated Smoke Tests via Newman

You can run automated smoke tests across all endpoints locally using `newman`:

```bash
npx newman run docs/postman_collection.json -e docs/postman_environment.json
```

---

## 5. API Key Management & Secret Rotation Process

1. **Environment Isolation**: Secrets (`JWT_SECRET`, `CHAPA_SECRET_KEY`) must never be hardcoded into source control.
2. **Secret Rotation Note**:
   - When rotating `JWT_SECRET`, all existing active access tokens will expire immediately.
   - When rotating `JWT_REFRESH_SECRET`, users will be required to log in again.
   - In production, update secrets via your hosting dashboard (e.g. Render, Heroku, AWS Secrets Manager) and perform a rolling restart.
