import jwt from 'jsonwebtoken';
import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import User from '../models/user.model.js';

export const authenticate = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new httpErrors.Unauthorized('Authentication token required');
  }

  const token = authHeader.split(' ')[1];
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('-password');
    
    if (!user) {
      throw new httpErrors.NotFound('User not found');
    }
    
    req.user = user;
    next();
  } catch (error) {
    throw new httpErrors.Unauthorized('Invalid or expired token');
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

export const handleTokenRefresh = asyncHandler(async (req, res, next) => {
  const { refreshToken } = req.body;
  
  if (refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      const newAccessToken = jwt.sign(
        { id: decoded.id },
        process.env.JWT_SECRET,
        { expiresIn: '15m' }
      );
      res.set('New-Access-Token', newAccessToken);
    } catch (error) {
      // Continue even if refresh fails - user will need to re-authenticate
    }
  }
  next();
});