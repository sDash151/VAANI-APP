import express from 'express';
import authRoutes from './auth.routes.js';
import contentRoutes from './content.routes.js';
import translationRoutes from './translation.routes.js';
import userRoutes from './user.routes.js';
import healthRoutes from './health.routes.js';
import rateLimit from 'express-rate-limit';

const router = express.Router();

// Global rate limiter (100 requests per 15 minutes)
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests, please try again later'
});

router.use(globalLimiter);

// Health check endpoint (should be before 404 handler)
router.use('/health', healthRoutes);

// API routes
router.use('/auth', authRoutes);
router.use('/content', contentRoutes);
router.use('/translate', translationRoutes);
router.use('/users', userRoutes);

export default router;