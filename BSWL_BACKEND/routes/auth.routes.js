import express from 'express';
import { 
  register, 
  login, 
  googleLogin, 
  refreshToken, 
  logout, 
  forgotPassword, 
  resetPassword, 
  syncUserProfile 
} from '../controllers/auth.controller.js';
import { validate } from '../middlewares/validation.middleware.js';
import { authSchemas } from '../middlewares/validation.middleware.js';

const router = express.Router();

// Signup (for frontend integration)
router.post('/signup', validate(authSchemas.register), register);

// Login (for frontend integration)
router.post('/login', validate(authSchemas.login), login);

// Google Login (for frontend integration)
router.post('/google-login', validate(authSchemas.googleLogin), googleLogin);

// Refresh Token (for frontend integration)
router.post('/refresh-token', validate(authSchemas.refreshToken), refreshToken);

// Logout (refresh token revocation)
router.post('/logout', logout);

// Forgot Password (for frontend integration)
router.post('/forgot-password', forgotPassword);

// Reset Password (for frontend integration)
router.post('/reset-password', resetPassword);

// Sync user profile (for frontend integration)
router.post('/sync-profile', syncUserProfile);

export default router;