# Real-Time Bus Reservation System — Frontend Integration Guide & Handoff

This guide provides Flutter mobile developers (Passenger App & Driver App) and React Web developers (Admin Dashboard) with detailed specifications for integrating with the backend REST API.

---

## 1. Authentication Flow & Refresh Strategy

### Endpoints
- `POST /auth/signup` — Register passenger/driver/admin account.
- `POST /auth/login` — Log in and receive `accessToken` (short-lived, 15m) and `refreshToken` (long-lived, 7d).
- `POST /auth/refresh` — Issue a new `accessToken` using `refreshToken`.
- `GET /auth/me` — Fetch authenticated user profile.

### Headers & Token Passing
For all protected endpoints, pass the access token in the HTTP Authorization header:
```http
Authorization: Bearer <accessToken>
```

### Refresh Strategy on HTTP 401
When an API call returns `401 Unauthorized`:
1. Intercept the 401 response in your HTTP client (e.g. Dio interceptor or custom http client wrapper).
2. Call `POST /auth/refresh` with `{ "refreshToken": "<stored_refreshToken>" }`.
3. If successful, update the stored `accessToken` and retry the original failed request.
4. If refresh fails (e.g. 401/403 or invalid refresh token), clear local tokens and redirect the user to the Login screen.

---

## 2. Booking & Payment Integration Flow

### Booking Step
1. Call `POST /bookings` with `{ "trip_id": "<trip_id>" }`.
2. Response contains booking in `pending` state with `total_amount` (e.g. 350.00 ETB) and `id`.

### Payment Step (Chapa Gateway)
1. Call `POST /payments/initiate` with `{ "bookingId": "<booking_id>", "return_url": "bussystem://payments/success" }`.
2. The endpoint returns:
   ```json
   {
     "checkout_url": "https://checkout.chapa.co/checkout/payment/...",
     "payment": { "id": "...", "status": "pending" }
   }
   ```
3. Open `checkout_url` in a Mobile Webview (`webview_flutter`) or External Browser (`url_launcher`).
4. **Deep Link / Callback Handling**:
   - `return_url` can be a custom mobile deep link: `bussystem://payments/success` or web URL `http://localhost:3000/payments/success`.
   - When the user completes payment on Chapa, Chapa triggers our backend webhook (`POST /payments/webhook`) which verifies the transaction via Chapa API and updates the booking status to `confirmed`.
   - The frontend should poll `GET /payments/:id` or `GET /bookings/:id` upon returning from the browser/webview until `status === "confirmed"`.

---

## 3. QR Ticket Generation & Verification Flow

### Passenger Ticket Display
1. Call `POST /tickets/:bookingId/generate` (requires `confirmed` booking).
2. The response returns:
   - `qr_code_image_url`: Relative path to PNG image (e.g. `/uploads/tickets/<ticket_id>.png`). Prepend base backend URL: `http://localhost:3000/uploads/tickets/<ticket_id>.png`.
   - `qr_code_data`: HMAC-SHA256 signed base64 payload.
3. Display the image using `Image.network(fullUrl)` or render `qr_code_data` using `qr_flutter`.

### Driver Ticket Scanner Validation
1. Driver App scans the passenger's QR code using a QR scanner library (`mobile_scanner` or `qr_code_scanner`).
2. Driver App calls `POST /tickets/validate` with `{ "qr_code_data": "<scanned_base64_string>" }`.
3. Response:
   - Success: `{ "valid": true, "ticket": { "id": "...", "status": "used" } }`
   - Invalid/Tampered: `{ "valid": false, "reason": "Invalid signature / tampered QR payload" }`
   - Already Used: `{ "valid": false, "reason": "Ticket has already been used" }`

---

## 4. GPS Real-Time Bus Tracking Flow

### Driver App (GPS Reporting)
Driver App posts periodic GPS coordinates (every 5–10 seconds while trip is `in_transit`):
- Endpoint: `POST /tracking/report`
- Payload:
  ```json
  {
    "tripId": "<trip_id>",
    "latitude": 9.0222,
    "longitude": 38.7468,
    "speed_kmh": 65.0,
    "heading": 180
  }
  ```

### Passenger App (GPS Viewing)
- **Option A (Real-Time SSE Stream)**:
  Connect to Server-Sent Events stream: `GET /tracking/:tripId/stream` (headers: `Authorization: Bearer <token>`).
- **Option B (Polling Fallback)**:
  Poll `GET /tracking/:tripId/recent?limit=1` every 5 seconds.

---

## 5. Standardized Error Handling

All error responses from the backend follow a strict JSON schema:
```json
{
  "error": "Human-readable error description message"
}
```

### HTTP Status Code Guidelines
- `400 Bad Request`: Validation failure (e.g. invalid email format, double booking attempt).
- `401 Unauthorized`: Token missing, invalid, or expired.
- `403 Forbidden`: Insufficient role permissions (e.g. passenger trying to call driver endpoint).
- `404 Not Found`: Resource does not exist (e.g. invalid bookingId/tripId).
- `502 Bad Gateway`: External Chapa payment API error.
