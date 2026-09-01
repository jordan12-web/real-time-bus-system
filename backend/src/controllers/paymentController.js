import crypto from 'crypto';
import { initiatePayment, handleWebhook, getPaymentById, verifyAndSyncPayment, listAllPayments } from '../services/paymentService.js';


const isValidChapaSignature = (req) => {
  const secret = process.env.CHAPA_WEBHOOK_SECRET;
  if (!secret) {
    console.warn('CHAPA_WEBHOOK_SECRET is not set — webhook signature is NOT being verified.');
    return true;
  }

  const expectedHash = crypto
    .createHmac('sha256', secret)
    .update(JSON.stringify(req.body))
    .digest('hex');

  const chapaSig = req.headers['chapa-signature'];
  const xChapaSig = req.headers['x-chapa-signature'];

  return chapaSig === expectedHash || xChapaSig === expectedHash;
};

export const postInitiatePayment = async (req, res, next) => {
  try {
    const { bookingId, return_url } = req.body;
    if (!bookingId) {
      return res.status(400).json({ error: 'bookingId is required' });
    }

    const result = await initiatePayment({
      bookingId,
      userId: req.user.id,
      return_url
    });

    return res.status(201).json(result);
  } catch (error) {
    next(error);
  }
};

export const postWebhook = async (req, res, next) => {
  try {
    if (!isValidChapaSignature(req)) {
      console.warn('Rejected webhook call with invalid/missing Chapa signature.');
      return res.status(401).json({ error: 'Invalid webhook signature' });
    }
    await handleWebhook(req.body);
    return res.status(200).json({ received: true });
  } catch (error) {
    next(error);
  }
};

export const getPayment = async (req, res, next) => {
  try {
    const payment = await getPaymentById(req.params.id, req.user.id, req.user.role);
    return res.status(200).json({ payment });
  } catch (error) {
    next(error);
  }
};

export const postVerifyPayment = async (req, res, next) => {
  try {
    const result = await verifyAndSyncPayment(req.params.id, req.user.id, req.user.role);
    return res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

export const getAllPayments = async (req, res, next) => {
  try {
    const payments = await listAllPayments();
    return res.status(200).json(payments);
  } catch (error) {
    next(error);
  }
};