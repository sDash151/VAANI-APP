import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import admin from '../config/firebase.js';
import User from '../models/user.model.js';
import logger from '../utils/logger.js';

export const authenticate = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new httpErrors.Unauthorized('Firebase ID token required');
  }
  
  // If Firebase is not configured, skip authentication for testing
  if (!admin) {
    logger.warn('Firebase not configured. Skipping authentication for testing.');
    req.user = { uid: 'test-user', email: 'test@example.com', role: 'user' };
    return next();
  }
  
  const idToken = authHeader.split(' ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    let user = await User.findOne({ uid: decodedToken.uid });
    if (!user) {
      // Optionally, create a user profile if not found
      user = await User.create({
        uid: decodedToken.uid,
        email: decodedToken.email,
        fullName: decodedToken.name,
        photoUrl: decodedToken.picture
      });
    }
    req.user = user;
    next();
  } catch (error) {
    throw new httpErrors.Unauthorized('Invalid or expired Firebase ID token');
  }
});

export const authorize = (roles = []) => {
  return (req, res, next) => {
    if (roles.length && !roles.includes(req.user.role)) {
      throw new httpErrors.Forbidden('Insufficient permissions');
    }
    next();
  };
};