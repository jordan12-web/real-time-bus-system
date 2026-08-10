import express from 'express';
import { postTrip, getTrips, getTrip } from '../controllers/tripController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.get('/', getTrips);
router.get('/:id', getTrip);
router.post('/', authenticate, authorize('admin', 'driver'), postTrip);

export default router;
