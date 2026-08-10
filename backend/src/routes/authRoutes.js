import express from 'express';
import { signup, login, getMe, refresh } from '../controllers/authController.js';
import { authenticate } from '../middlewares/auth.js';

const router = express.Router();

router.post('/signup', signup);
router.post('/login', login);
router.post('/refresh', refresh);
router.get('/me', authenticate, getMe);

export default router;
