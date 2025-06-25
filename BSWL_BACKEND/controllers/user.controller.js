import User from '../models/user.model.js';
import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';

export const getUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).select('-password');
  res.json(user);
});

export const updateUserProfile = asyncHandler(async (req, res) => {
  const updates = Object.keys(req.body);
  const allowedUpdates = ['preferences.language', 'preferences.notificationEnabled'];
  const isValidOperation = updates.every(update => allowedUpdates.includes(update));

  if (!isValidOperation) {
    throw new httpErrors.BadRequest('Invalid updates!');
  }

  const user = await User.findById(req.user._id);
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }

  updates.forEach(update => {
    const [parent, child] = update.split('.');
    user[parent][child] = req.body[update];
  });

  await user.save();
  res.json(user);
});

export const updateProgress = asyncHandler(async (req, res) => {
  const { lessonId, score } = req.body;
  
  if (!lessonId || typeof score !== 'number') {
    throw new httpErrors.BadRequest('Invalid progress data');
  }

  const user = await User.findById(req.user._id);
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }

  // Update progress map
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
  const user = await User.findById(req.user._id);
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  user.refreshTokens = []; // Invalidate all refresh tokens before deleting
  await user.save();
  await User.findByIdAndDelete(req.user._id);
  res.status(200).json({ message: 'Account deleted successfully. All sessions have been logged out.' });
});
