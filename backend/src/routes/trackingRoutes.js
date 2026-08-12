import express from 'express';
import { postReportLocation, getTripRecentLocations, streamTripLocations } from '../controllers/trackingController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.use(authenticate);

router.post('/report', authorize('driver', 'admin'), postReportLocation);
router.get('/:tripId/recent', getTripRecentLocations);
router.get('/:tripId/stream', streamTripLocations);

export default router;
