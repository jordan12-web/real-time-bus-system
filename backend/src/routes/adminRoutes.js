import express from 'express';
import { getStats } from '../controllers/adminController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.use(authenticate, authorize('admin'));

router.get('/stats', getStats);

export default router;