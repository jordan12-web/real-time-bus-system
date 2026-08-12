import express from 'express';
import { postGenerateTicket, postValidateTicket, postRevokeTicket } from '../controllers/ticketController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.use(authenticate);

router.post('/:bookingId/generate', postGenerateTicket);
router.post('/validate', authorize('driver', 'admin'), postValidateTicket);
router.post('/:id/revoke', authorize('admin'), postRevokeTicket);

export default router;
