import express from 'express';
import { postInitiatePayment, postWebhook, getPayment } from '../controllers/paymentController.js';
import { authenticate } from '../middlewares/auth.js';

const router = express.Router();

router.post('/webhook', postWebhook);
router.post('/initiate', authenticate, postInitiatePayment);
router.get('/:id', authenticate, getPayment);

export default router;
