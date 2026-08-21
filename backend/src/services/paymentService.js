import Payment from '../models/Payment.js';
import Booking from '../models/Booking.js';
import User from '../models/User.js';

const CHAPA_INITIALIZE_URL = 'https://api.chapa.co/v1/transaction/initialize';
const CHAPA_VERIFY_URL = 'https://api.chapa.co/v1/transaction/verify';

export const initiatePayment = async ({ bookingId, userId, return_url }) => {
  const booking = await Booking.findById(bookingId);
  if (!booking) {
    const error = new Error('Booking not found');
    error.statusCode = 404;
    throw error;
  }

  if (booking.user_id.toString() !== userId) {
    const error = new Error('Forbidden: Access denied to this booking');
    error.statusCode = 403;
    throw error;
  }

  if (booking.status === 'confirmed') {
    const error = new Error('Booking is already paid and confirmed');
    error.statusCode = 400;
    throw error;
  }

  if (booking.status === 'cancelled' || booking.status === 'expired') {
    const error = new Error('Cannot initiate payment for a cancelled or expired booking');
    error.statusCode = 400;
    throw error;
  }

  const existingPayment = await Payment.findOne({
    booking_id: booking._id,
    status: 'pending',
    chapa_checkout_url: { $ne: null }
  });

  if (existingPayment) {
    return {
      checkout_url: existingPayment.chapa_checkout_url,
      payment: existingPayment.toJSON()
    };
  }

  const user = await User.findById(userId);
  const userEmail = user?.email || 'passenger@example.com';
  const fullName = user?.full_name || 'Passenger';
  const nameParts = fullName.trim().split(' ');
  const first_name = nameParts[0] || 'Passenger';
  const last_name = nameParts.slice(1).join(' ') || 'User';

  const chapa_tx_ref = `tx-${bookingId}-${Date.now()}`;

  const payment = await Payment.create({
    booking_id: booking._id,
    amount: booking.total_amount,
    currency: booking.currency || 'ETB',
    status: 'pending',
    chapa_tx_ref
  });

  const backendBaseUrl = process.env.BACKEND_BASE_URL || 'https://real-time-bus-system.onrender.com';

  const chapaPayload = {
    amount: booking.total_amount.toString(),
    currency: booking.currency || 'ETB',
    email: userEmail,
    first_name,
    last_name,
    tx_ref: chapa_tx_ref,
    return_url: return_url || 'http://localhost:3000/payments/success',
    callback_url: `${backendBaseUrl}/payments/webhook`,
    customization: {
      title: 'Bus Ticket',
      description: `Payment for booking ${bookingId}`
    }
  };

  try {
    const response = await fetch(CHAPA_INITIALIZE_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.CHAPA_SECRET_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(chapaPayload)
    });

    const data = await response.json();

    if (!response.ok || data.status !== 'success') {
      console.error('Chapa Initialization Gateway Error:', data);
      payment.status = 'failed';
      await payment.save();

      const message = typeof data.message === 'string'
        ? data.message
        : 'Chapa payment gateway initialization failed';

      const error = new Error(message);
      error.statusCode = 502;
      throw error;
    }

    payment.chapa_checkout_url = data.data.checkout_url;
    await payment.save();

    return {
      checkout_url: data.data.checkout_url,
      payment: payment.toJSON()
    };
  } catch (err) {
    if (err.statusCode) throw err;
    console.error('Payment gateway exception:', err.message);
    const error = new Error(`Payment gateway error: ${err.message}`);
    error.statusCode = 502;
    throw error;
  }
};

export const verifyPaymentByTxRef = async (tx_ref) => {
  try {
    const response = await fetch(`${CHAPA_VERIFY_URL}/${tx_ref}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${process.env.CHAPA_SECRET_KEY}`
      }
    });

    const data = await response.json();
    if (!response.ok) {
      console.error('Chapa Verification Gateway Error:', data);
      const error = new Error(data.message || 'Chapa transaction verification failed');
      error.statusCode = 400;
      throw error;
    }

    return data;
  } catch (err) {
    if (err.statusCode) throw err;
    console.error('Chapa verification exception:', err.message);
    const error = new Error(`Chapa verification error: ${err.message}`);
    error.statusCode = 502;
    throw error;
  }
};

const applyVerificationResult = async (payment, verification) => {
  const booking = await Booking.findById(payment.booking_id);

  if (verification.status === 'success' && verification.data?.status === 'success') {
    payment.status = 'success';
    await payment.save();

    if (booking) {
      booking.status = 'confirmed';
      await booking.save();
    }
  } else if (verification.data?.status && verification.data.status !== 'pending') {
    // Any terminal non-success status from Chapa (failed, cancelled, etc.) —
    // don't mark failed just because it's still pending mid-checkout.
    payment.status = 'failed';
    await payment.save();

    if (booking) {
      booking.status = 'cancelled';
      await booking.save();
    }
  }

  return { payment: payment.toJSON(), booking: booking ? booking.toJSON() : null };
};

export const handleWebhook = async (payload) => {
  const tx_ref = payload.tx_ref || payload.chapa_tx_ref || payload.trx_ref || payload.reference;
  if (!tx_ref) {
    const error = new Error('Missing transaction reference in payload');
    error.statusCode = 400;
    throw error;
  }

  const payment = await Payment.findOne({ chapa_tx_ref: tx_ref });
  if (!payment) {
    const error = new Error(`Payment record not found for ref ${tx_ref}`);
    error.statusCode = 404;
    throw error;
  }

  const verification = await verifyPaymentByTxRef(tx_ref);
  return applyVerificationResult(payment, verification);
};

/// Actively re-checks a payment's status directly against Chapa's verify
/// API, instead of passively waiting for Chapa's webhook to call us. Safe
/// to call repeatedly (e.g. from client polling) — if the payment is
/// already resolved (not 'pending'), it returns immediately without
/// hitting Chapa again. This exists specifically because webhook delivery
/// is not guaranteed to be fast or to arrive at all in a sandbox setup —
/// this gives the client a reliable way to reach a final status either way.
export const verifyAndSyncPayment = async (id, userId, role) => {
  const payment = await Payment.findById(id);
  if (!payment) {
    const error = new Error('Payment not found');
    error.statusCode = 404;
    throw error;
  }

  const booking = await Booking.findById(payment.booking_id);
  if (role !== 'admin' && booking && booking.user_id.toString() !== userId) {
    const error = new Error('Forbidden: Access denied to this payment record');
    error.statusCode = 403;
    throw error;
  }

  if (payment.status !== 'pending') {
    return { payment: payment.toJSON(), booking: booking ? booking.toJSON() : null };
  }

  const verification = await verifyPaymentByTxRef(payment.chapa_tx_ref);
  return applyVerificationResult(payment, verification);
};

export const getPaymentById = async (id, userId, role) => {
  const payment = await Payment.findById(id).populate('booking_id');
  if (!payment) {
    const error = new Error('Payment not found');
    error.statusCode = 404;
    throw error;
  }

  const booking = payment.booking_id;
  if (role !== 'admin' && booking && booking.user_id.toString() !== userId) {
    const error = new Error('Forbidden: Access denied to this payment record');
    error.statusCode = 403;
    throw error;
  }

  return payment.toJSON();
};