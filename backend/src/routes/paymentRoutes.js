import express from 'express';
import { postInitiatePayment, postWebhook, getPayment, postVerifyPayment } from '../controllers/paymentController.js';
import { authenticate } from '../middlewares/auth.js';

const router = express.Router();

router.post('/webhook', postWebhook);
router.post('/initiate', authenticate, postInitiatePayment);
router.get('/:id', authenticate, getPayment);
router.post('/:id/verify', authenticate, postVerifyPayment);

export default router;