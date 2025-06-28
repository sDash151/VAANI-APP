  import httpErrors from 'http-errors';
  import asyncHandler from 'express-async-handler';
  import admin from '../config/firebase.js';
  import User from '../models/user.model.js';

  // Firebase token verification middleware
  export const authenticate = asyncHandler(async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new httpErrors.Unauthorized('Firebase ID token required');
    }
    const idToken = authHeader.split(' ')[1];
    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      // Only set uid and email (and optionally name, picture) on req.user
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        fullName: decodedToken.name,
        photoUrl: decodedToken.picture
      };
      next();
    } catch (error) {
      throw new httpErrors.Unauthorized('Invalid or expired Firebase ID token');
    }
  });

  // Utility functions for validation
  function isValidUrl(url) {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  function isValidLength(str, max) {
    return typeof str === 'string' && str.length <= max;
  }

  // Refactored syncUserProfile controller
  export const syncUserProfile = asyncHandler(async (req, res) => {
    const { fullName, photoUrl } = req.body;
    const { uid, email } = req.user;

    // Optional: Validate fields
    if (fullName && !isValidLength(fullName, 100)) {
      throw new httpErrors.BadRequest('Full name is too long (max 100 characters)');
    }
    if (photoUrl && (!isValidLength(photoUrl, 300) || !isValidUrl(photoUrl))) {
      throw new httpErrors.BadRequest('Invalid photo URL');
    }

    // Use findOneAndUpdate with upsert for atomic operation
    const user = await User.findOneAndUpdate(
      { uid },
      {
        $set: {
          email,
          ...(fullName && { fullName }),
          ...(photoUrl && { photoUrl })
        }
      },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({ message: 'User profile synced successfully', user });
  });

  // Example route protection (in your routes/auth.routes.js):
  // import { authenticate, syncUserProfile } from '../controllers/auth.controller.js';
  // router.post('/sync-profile', authenticate, syncUserProfile);