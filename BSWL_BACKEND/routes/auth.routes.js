import express from 'express';
import { syncUserProfile } from '../controllers/auth.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Sync user profile (for frontend integration)
router.post('/sync-profile', authenticate, syncUserProfile);

export default router;