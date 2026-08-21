import { initiatePayment, handleWebhook, getPaymentById } from '../services/paymentService.js';

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
    console.log('Incoming Chapa webhook:', JSON.stringify(req.body).slice(0, 1000));
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
