import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import User from '../models/user.model.js';
import firebaseAdmin from '../config/firebase.js';
import nodemailer from 'nodemailer';

const generateTokens = (userId) => {
  const accessToken = jwt.sign(
    { id: userId },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );
  const refreshToken = jwt.sign(
    { id: userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );
  return { accessToken, refreshToken };
};

export const register = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  
  if (await User.findOne({ email })) {
    throw new httpErrors.Conflict("Email already registered");
  }

  const user = await User.create({
    email,
    password: bcrypt.hashSync(password, 10),
    preferences: { language: 'english' },
    refreshTokens: []
  });

  const { accessToken, refreshToken } = generateTokens(user._id);
  user.refreshTokens.push(refreshToken);
  await user.save();
  res.status(201).json({ accessToken, refreshToken });
});

export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email }).select('+password');
  
  if (!user || !bcrypt.compareSync(password, user.password)) {
    throw new httpErrors.Unauthorized('Invalid credentials');
  }

  const { accessToken, refreshToken } = generateTokens(user._id);
  user.refreshTokens.push(refreshToken);
  await user.save();
  res.json({ accessToken, refreshToken });
});

export const googleLogin = asyncHandler(async (req, res) => {
  const { idToken } = req.body;
  const decoded = await firebaseAdmin.auth().verifyIdToken(idToken);
  
  let user = await User.findOne({ email: decoded.email });
  if (!user) {
    user = await User.create({
      email: decoded.email,
      preferences: { language: 'english' },
      refreshTokens: []
    });
  }

  const { accessToken, refreshToken } = generateTokens(user._id);
  user.refreshTokens.push(refreshToken);
  await user.save();
  res.json({ accessToken, refreshToken });
});

export const refreshToken = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) throw new httpErrors.BadRequest('Refresh token required');
  
  const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  const accessToken = jwt.sign(
    { id: decoded.id },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );
  
  res.json({ accessToken });
});

export const logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ message: 'Refresh token required' });
  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const user = await User.findById(decoded.id);
    if (user && user.refreshTokens) {
      user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
      await user.save();
    }
  } catch (e) {
    // Ignore errors for invalid/expired token
  }
  res.status(200).json({ message: 'Logged out' });
});

export const forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;
  if (!email) {
    throw new httpErrors.BadRequest('Email is required');
  }
  const user = await User.findOne({ email });
  if (!user) {
    // For security, don't reveal if user exists
    return res.status(200).json({ message: 'Password reset email sent' });
  }

  // Generate a password reset token (JWT, expires in 1 hour)
  const resetToken = jwt.sign(
    { id: user._id },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
  const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:8080'}/reset-password?token=${resetToken}`;

  // Send email (using nodemailer, configure as needed)
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Password Reset Request',
    html: `<p>You requested a password reset. <a href="${resetUrl}">Click here to reset your password</a>. This link will expire in 1 hour.</p>`
  });

  res.status(200).json({ message: 'Password reset email sent' });
});

export const resetPassword = asyncHandler(async (req, res) => {
  const { token, newPassword } = req.body;
  if (!token || !newPassword) {
    throw new httpErrors.BadRequest('Token and new password are required');
  }
  let decoded;
  try {
    decoded = jwt.verify(token, process.env.JWT_SECRET);
  } catch (e) {
    throw new httpErrors.BadRequest('Invalid or expired token');
  }
  const user = await User.findById(decoded.id);
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  user.password = bcrypt.hashSync(newPassword, 10);
  user.refreshTokens = []; // Invalidate all refresh tokens on password reset
  await user.save();
  res.status(200).json({ message: 'Password has been reset successfully. All sessions have been logged out.' });
});

export const syncUserProfile = asyncHandler(async (req, res) => {
  const { uid, fullName, email, photoUrl } = req.body;
  if (!uid || !email) {
    throw new httpErrors.BadRequest('uid and email are required');
  }
  let user = await User.findOne({ uid });
  if (!user) {
    user = await User.findOne({ email });
  }
  if (!user) {
    throw new httpErrors.NotFound('User not found');
  }
  if (fullName) user.fullName = fullName;
  if (photoUrl) user.photoUrl = photoUrl;
  await user.save();
  res.status(200).json({ message: 'User profile synced successfully' });
});