import express from 'express';
import { postInitiatePayment, postWebhook, getPayment, postVerifyPayment, getAllPayments } from '../controllers/paymentController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.post('/webhook', postWebhook);
router.get('/', authenticate, authorize('admin'), getAllPayments);
router.post('/initiate', authenticate, postInitiatePayment);
router.get('/:id', authenticate, getPayment);
router.post('/:id/verify', authenticate, postVerifyPayment);

export default router;