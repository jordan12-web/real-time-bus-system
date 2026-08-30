import express from 'express';
import { postTrip, getTrips, getTrip, getTripBookings } from '../controllers/tripController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.get('/', getTrips);
router.get('/:id', getTrip);
router.get('/:id/bookings', authenticate, authorize('admin', 'driver'), getTripBookings);
router.post('/', authenticate, authorize('admin', 'driver'), postTrip);

export default router;