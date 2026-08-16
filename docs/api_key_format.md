# API Key Format Notes

The Flutter passenger app treats incoming backend JSON as camelCase at the
service boundary. `passenger_app/lib/core/json_adapter.dart` recursively
normalizes response keys from snake_case to camelCase before repositories and
models parse the data.

Outgoing request bodies are not globally transformed. Each service builds the
payload expected by its endpoint:

| Endpoint | Request key format | Passenger app rule |
| :--- | :--- | :--- |
| `POST /auth/signup` | snake_case for profile fields | Send `full_name` and `phone_number`. |
| `POST /bookings` | snake_case | Send `trip_id`. |
| `POST /payments/initiate` | camelCase | Send `bookingId` and `returnUrl` when present. |
| `POST /tickets/validate` | snake_case | Send `qr_code_data`. |
| `POST /tracking/report` | mixed documented contract | Send `tripId`; optional speed remains `speed_kmh`. |

OpenAPI and the Postman collection currently disagree on the optional payment
return URL key: OpenAPI lists `return_url`, while this client now sends
`returnUrl` per the casing-normalization task. Live staging behavior should be
used to reconcile this contract discrepancy before backend changes are made.
