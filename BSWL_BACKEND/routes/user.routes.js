import express from 'express';
const router = express.Router();

import {
  getUserProfile as getCurrentUser,
  updateUserProfile as updateProfile,
  deleteAccount,
  getAllUsers,
  getUserById,
  adminUpdateUser,
  adminDeleteUser
} from '../controllers/user.controller.js';

import { authenticate, authorize } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';
import { userSchemas } from '../middlewares/validation.middleware.js'; // or wherever it's defined

router.use(authenticate);

// Get current user's profile
router.get('/me', getCurrentUser);

// Update user profile
router.put('/me', validate(userSchemas.updateProfile), updateProfile);

// Delete user account
router.delete('/me', deleteAccount);

// Public user profile endpoint for frontend demo
router.get('/profile', (req, res) => {
  res.json({
    uid: 'demo123',
    fullName: 'Demo User',
    email: 'demo@example.com',
    photoUrl: null,
    streak: 5,
    enrolledCourses: 12,
    completedCourses: 8,
    learningHours: 42,
    achievements: [
      { type: 'Master', count: 3 },
      { type: 'Streak', count: 16 },
      { type: 'Speedster', count: 2 },
      { type: 'Pro', count: 5 },
    ],
  });
});

// Admin-only routes
router.use(authorize(['admin']));

router.get('/', getAllUsers);
router.get('/:userId', getUserById);
router.put('/:userId', validate(userSchemas.updateProfile), adminUpdateUser);
router.delete('/:userId', adminDeleteUser);

export default router;
