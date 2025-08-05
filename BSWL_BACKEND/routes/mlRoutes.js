import express from 'express';
import { translateVideo, checkMLHealth, getMLStatus, upload } from '../controllers/mlController.js';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Health check endpoint (public)
router.get('/health', checkMLHealth);

// Status endpoint (public)
router.get('/status', getMLStatus);

// Video translation endpoint (protected)
router.post('/translate', authenticate, upload.single('video'), translateVideo);

export default router; 