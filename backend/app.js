import express from "express";
import authRoutes from "./src/routes/authRoutes.js";
import tripRoutes from "./src/routes/tripRoutes.js";
import bookingRoutes from "./src/routes/bookingRoutes.js";
import paymentRoutes from "./src/routes/paymentRoutes.js";

const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
  res.status(200).json({ status: "OK" });
});

app.use("/auth", authRoutes);
app.use("/trips", tripRoutes);
app.use("/bookings", bookingRoutes);
app.get("/payments/success", (req, res) => {
  res.send("Payment completed successfully. You can close this page.");
});

app.get("/payments/failure", (req, res) => {
  res.send("Payment failed. Please try again.");
});
app.use("/payments", paymentRoutes);

app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";
  res.status(statusCode).json({ error: message });
});

export default app;
