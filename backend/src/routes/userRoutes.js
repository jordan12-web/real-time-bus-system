import express from 'express';
import { getUsers, patchUserRole } from '../controllers/userController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorize } from '../middlewares/role.js';

const router = express.Router();

router.use(authenticate, authorize('admin'));

router.get('/', getUsers);
router.patch('/:id/role', patchUserRole);

export default router;