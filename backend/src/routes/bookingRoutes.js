import express from 'express';
import { postBooking, getBooking, deleteBooking, getMyBookings } from '../controllers/bookingController.js';
import { authenticate } from '../middlewares/auth.js';

const router = express.Router();

router.use(authenticate);

router.post('/', postBooking);
router.get('/', getMyBookings);
router.get('/:id', getBooking);
router.delete('/:id', deleteBooking);

export default router;