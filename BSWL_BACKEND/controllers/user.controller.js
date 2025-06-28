import User from '../models/user.model.js';
import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';

// Utility functions for validation
function isValidLength(str, max) {
  return typeof str === 'string' && str.length <= max;
}

// Get current user's profile (by Firebase UID)
export const getUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findOne({ uid: req.user.uid }).select('-password');
  if (!user) throw new httpErrors.NotFound('User not found');
  res.json(user);
});

// Update user profile (only allowed fields, for authenticated user)
export const updateUserProfile = asyncHandler(async (req, res) => {
  const allowedUpdates = ['preferences.language', 'preferences.notificationEnabled', 'fullName', 'photoUrl'];
  const updates = Object.keys(req.body);
  const isValidOperation = updates.every(update => allowedUpdates.includes(update));
  if (!isValidOperation) {
    throw new httpErrors.BadRequest('Invalid updates!');
  }
  // Optional: Validate fullName and photoUrl
  if (req.body.fullName && !isValidLength(req.body.fullName, 100)) {
    throw new httpErrors.BadRequest('Full name is too long (max 100 characters)');
  }
  if (req.body.photoUrl && !isValidLength(req.body.photoUrl, 300)) {
    throw new httpErrors.BadRequest('Photo URL is too long (max 300 characters)');
  }
  const user = await User.findOneAndUpdate(
    { uid: req.user.uid },
    { $set: req.body },
    { new: true }
  );
  if (!user) throw new httpErrors.NotFound('User not found');
  res.json(user);
});

export const updateProgress = asyncHandler(async (req, res) => {
  const { lessonId, score } = req.body;
  if (!lessonId || typeof score !== 'number') {
    throw new httpErrors.BadRequest('Invalid progress data');
  }
  const user = await User.findOne({ uid: req.user.uid });
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  user.progress.set(lessonId, score);
  // Calculate overall progress
  const totalLessons = 50; // This should come from content service
  const completedLessons = user.progress.size;
  user.overallProgress = Math.round((completedLessons / totalLessons) * 100);
  await user.save();
  res.json({
    progress: user.progress.get(lessonId),
    overallProgress: user.overallProgress
  });
});

// Admin - Get all users
export const getAllUsers = asyncHandler(async (req, res) => {
  const users = await User.find().select('-password');
  res.json(users);
});

// Admin - Get user by ID
export const getUserById = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.userId).select('-password');
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  res.json(user);
});

// Admin - Update user by ID
export const adminUpdateUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.userId);
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  const updates = req.body;
  Object.keys(updates).forEach(key => {
    user[key] = updates[key];
  });
  await user.save();
  res.json(user);
});

// Admin - Delete user by ID
export const adminDeleteUser = asyncHandler(async (req, res) => {
  const user = await User.findByIdAndDelete(req.params.userId);
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  res.status(200).json({ message: 'User deleted successfully' });
});

export const deleteAccount = asyncHandler(async (req, res) => {
  const user = await User.findOneAndDelete({ uid: req.user.uid });
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  res.status(200).json({ message: 'Account deleted successfully.' });
});
