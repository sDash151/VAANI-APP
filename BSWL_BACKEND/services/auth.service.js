import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import User from '../models/user.model.js';
import ActivityLog from '../models/log.model.js';

export const generateTokens = (userId) => {
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

export const registerUser = async (email, password) => {
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new Error('Email already registered');
  }

  const hashedPassword = bcrypt.hashSync(password, 10);
  return await User.create({
    email,
    password: hashedPassword
  });
};

export const loginUser = async (email, password) => {
  const user = await User.findOne({ email }).select('+password');
  
  if (!user || !bcrypt.compareSync(password, user.password)) {
    throw new Error('Invalid credentials');
  }

  // Update last login
  user.lastLogin = new Date();
  await user.save();
  
  // Log activity
  await ActivityLog.create({
    userId: user._id,
    action: 'login',
    ipAddress: req.ip,
    userAgent: req.get('User-Agent')
  });

  return user;
};

export const refreshAccessToken = (refreshToken) => {
  const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  return jwt.sign(
    { id: decoded.id },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );
};