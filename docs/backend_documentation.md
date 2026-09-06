# Guzo Real-Time Bus System — Backend Architecture & Technical Guide

---

## 1. System Overview & Architecture

The **Guzo Backend** is the core RESTful API and event-streaming service powering the entire Real-Time Bus Reservation & Tracking System. Built on **Node.js** (using modern ES Modules `type: "module"`) and **Express.js**, it uses **MongoDB** (via **Mongoose ODM**) for data persistence.

### High-Level Architecture & Layering Pattern
The backend enforces a clean **3-tier layered architecture**:
```
┌─────────────────────────────────────────────────────────┐
│              HTTP Requests / SSE Clients                │
│         (Passenger App, Driver App, Admin Web)          │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│               Routes & Controllers Layer                │
│    (routes/*, controllers/* - HTTP parsing & status)    │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    Services Layer                       │
│    (services/* - Business logic, HMAC, Chapa, SSE)     │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│               Database Models (Mongoose)                │
│       (models/User, Trip, Booking, Ticket, etc.)        │
└────────────────────────────┴────────────────────────────┘
```

- **Routes (`routes/`):** Map HTTP endpoints to controller handlers and apply authentication (`authenticate`) and role authorization (`authorize(['admin'])`) middleware.
- **Controllers (`controllers/`):** Validate input parameters, handle HTTP status codes (200, 201, 400, 403, 404, 500), and delegate business rules to services.
- **Services (`services/`):** Pure, reusable business logic isolated from HTTP request/response objects (e.g. calculating seat pricing, generating HMAC signatures, handling Chapa webhooks, emitting SSE events).
- **Models (`models/`):** Schema definitions with Mongoose middleware hooks (e.g. pre-save password hashing).

---

## 2. Technical Need-to-Knows & Code Snippets

### A. Authentication & Security (JWT + Bcrypt)
Authentication uses dual-token **JSON Web Tokens**:
1. **Access Token:** Short-lived JWT passed in `Authorization: Bearer <token>` header.
2. **Refresh Token:** Long-lived token stored securely (or in HTTP-only cookies).
3. **Password Hashing:** Passwords are auto-hashed using `bcrypt.hash(password, 10)` in a Mongoose `pre('save')` hook.

```javascript
// models/User.js - Automatic Password Hashing
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

UserSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};
```

#### Role-Based Access Control (RBAC Middleware)
```javascript
// middlewares/role.js
export const authorize = (allowedRoles = []) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized: User authentication required' });
    }
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: `Forbidden: Requires role [${allowedRoles.join(', ')}]` });
    }
    next();
  };
};
```

---

### B. Cryptographic Ticket QR Generation & Validation
To eliminate fake tickets and QR code tampering, QR payloads are signed using **HMAC-SHA256**:

```javascript
// services/ticketService.js - HMAC Signed QR Generation
const payloadData = {
  t: ticket._id.toString(),
  b: booking._id.toString(),
  u: booking.user_id.toString(),
  r: booking.trip_id.toString(),
  iat: Math.floor(Date.now() / 1000)
};

// Create HMAC signature over payload fields
const payloadString = `${payloadData.t}:${payloadData.b}:${payloadData.u}:${payloadData.r}:${payloadData.iat}`;
const sig = crypto.createHmac('sha256', JWT_SECRET).update(payloadString).digest('hex');

// Base64 encode full payload + signature for QR code
const fullPayload = { ...payloadData, sig };
const qr_code_data = Buffer.from(JSON.stringify(fullPayload)).toString('base64');
```

#### Ticket Validation Algorithm
When the driver scans the QR code, the backend verifies the cryptographic signature before checking ticket status:
```javascript
// Verification step in validateTicket()
const payloadString = `${t}:${b}:${u}:${r}:${iat}`;
const expectedSig = crypto.createHmac('sha256', JWT_SECRET).update(payloadString).digest('hex');

if (sig !== expectedSig) {
  return { valid: false, reason: 'Invalid signature / tampered QR payload' };
}

if (ticket.status === 'used') {
  return { valid: false, reason: 'Ticket has already been used' };
}
```

---

### C. Real-Time Location Streaming (Server-Sent Events)
Instead of high-overhead WebSocket connections for one-way bus position broadcasts, the system leverages light-weight **Server-Sent Events (SSE)** via Node's native `EventEmitter`:

```javascript
// services/trackingService.js
export const trackingEmitter = new EventEmitter();

export const reportLocation = async ({ tripId, latitude, longitude, speed_kmh, heading }) => {
  const location = new TripLocation({ trip_id: tripId, latitude, longitude, speed_kmh, heading });
  await location.save();
  
  // Broadcast location event to all active listener connections for this trip
  trackingEmitter.emit(`location:${tripId}`, location.toJSON());
  return location;
};

// controllers/trackingController.js - Stream Endpoint
export const streamTripLocations = (req, res) => {
  const { tripId } = req.params;
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  const onLocation = (location) => {
    res.write(`data: ${JSON.stringify(location)}\n\n`);
  };

  trackingEmitter.on(`location:${tripId}`, onLocation);
  req.on('close', () => trackingEmitter.removeListener(`location:${tripId}`, onLocation));
};
```

---

## 3. End-to-End Traced Technical Workflows

### Traced Workflow 1: Chapa Payment Verification & Automatic Booking Confirmation
```
Passenger               Backend / PaymentService               Chapa API Gateway
    │                              │                                  │
    │─── 1. POST /payments/checkout ─>                                 │
    │                              │─── 2. Initialize Txn ───────────>│
    │                              │<── 3. Return checkout_url ───────│
    │<── 4. Redirect to Chapa ─────│                                  │
    │                              │                                  │
    │======== Passenger Pays via Chapa / Telebirr Mobile Money =======│
    │                              │                                  │
    │                              │<── 5. Webhook / Callback Notification
    │                              │    (verify signature & status)   │
    │                              │─── 6. Verify Transaction ───────>│
    │                              │<── 7. Status = "success" ────────│
    │                              │                                  │
    │                              │─── 8. Update Booking status ➔ "confirmed"
    │                              │─── 9. Trigger generateTicket()
```

---

## 4. Anticipated Instructor Defense Q&A

> **Q1: Why did you choose Server-Sent Events (SSE) over WebSockets for bus tracking?**  
> **A:** Live bus tracking is inherently a **one-way stream** (Server ➔ Passenger App). SSE works over standard HTTP/1.1 or HTTP/2, requires no special proxy or firewall configuration, re-connects automatically, and uses significantly less memory on the Node server compared to maintaining full-duplex WebSocket connections for thousands of passive listeners.

> **Q2: How do you prevent ticket counterfeiting or QR screenshot reuse?**  
> **A:** Each QR code contains a payload encoded with an **HMAC-SHA256 cryptographic signature** generated using a server-side secret (`JWT_SECRET`). If an attacker alters the ticket ID or user ID in the QR payload, signature verification fails. Furthermore, once a ticket is scanned, its status in MongoDB transitions atomically to `used`, rendering any duplicated screenshots invalid for future admittance.

> **Q3: How do you handle database concurrency to prevent double-booking the same seat?**  
> **A:** When a passenger initiates a booking, Mongoose checks existing active bookings for that `trip_id` and `seat_number` within a database transaction or atomic query condition (`status: { $ne: 'cancelled' }`). If the seat is taken, a 409 Conflict error is returned.

---

## 5. Future Improvements & Roadmap
1. **Redis Pub/Sub for SSE Clustering:** Upgrade `EventEmitter` to Redis Pub/Sub so SSE broadcasts work across multiple load-balanced backend instances.
2. **Database Indexing:** Add compound geospatial 2dsphere indexes on `TripLocation` (`trip_id`, `location`, `recorded_at`) for fast spatial queries.
3. **Automated Refund Webhooks:** Extend Chapa payment service to process automated refunds upon trip cancellations.
