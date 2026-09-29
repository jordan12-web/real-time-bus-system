import express from 'express';
import { handleAiQuery } from '../controllers/aiController.js';
import { authenticate } from '../middlewares/auth.js';

const router = express.Router();


router.use(authenticate);


router.post('/query', handleAiQuery);

export default router;