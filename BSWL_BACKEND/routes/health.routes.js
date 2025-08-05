import express from 'express';
import mongoose from 'mongoose';
import { testConnection as testCloudinary } from '../config/cloudinary.js';
const router = express.Router();

// Health check route
router.get('/', async (req, res) => {
  const mongoStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  
  // Test Cloudinary connection
  let cloudinaryStatus = 'unknown';
  try {
    const cloudinaryConnected = await testCloudinary();
    cloudinaryStatus = cloudinaryConnected ? 'connected' : 'disconnected';
  } catch (error) {
    cloudinaryStatus = 'error';
  }
  
  res.status(200).json({ 
    success: true,
    message: 'Backend is working!',
    services: {
      mongodb: mongoStatus,
      cloudinary: cloudinaryStatus
    },
    timestamp: new Date().toISOString()
  });
});

export default router;
