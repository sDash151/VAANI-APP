import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Test Cloudinary connection
const testConnection = async () => {
  try {
    const result = await cloudinary.api.ping();
    logger.info('✅ Cloudinary connected successfully');
    return true;
  } catch (error) {
    logger.error('❌ Cloudinary connection failed:', error.message);
    return false;
  }
};

// Upload file to Cloudinary
const uploadFile = async (file, folder = 'bswl') => {
  try {
    const uploadResult = await cloudinary.uploader.upload(file.path, {
      folder: folder,
      resource_type: 'auto',
      allowed_formats: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi', 'mov', 'wmv'],
      transformation: [
        { quality: 'auto' },
        { fetch_format: 'auto' }
      ]
    });

    logger.info(`✅ File uploaded to Cloudinary: ${uploadResult.public_id}`);
    return {
      url: uploadResult.secure_url,
      public_id: uploadResult.public_id,
      format: uploadResult.format,
      size: uploadResult.bytes
    };
  } catch (error) {
    logger.error('❌ Cloudinary upload failed:', error.message);
    throw new Error(`Upload failed: ${error.message}`);
  }
};

// Upload video specifically
const uploadVideo = async (file, folder = 'bswl/videos') => {
  try {
    const uploadResult = await cloudinary.uploader.upload(file.path, {
      folder: folder,
      resource_type: 'video',
      allowed_formats: ['mp4', 'avi', 'mov', 'wmv', 'flv'],
      transformation: [
        { quality: 'auto' },
        { fetch_format: 'auto' }
      ]
    });

    logger.info(`✅ Video uploaded to Cloudinary: ${uploadResult.public_id}`);
    return {
      url: uploadResult.secure_url,
      public_id: uploadResult.public_id,
      format: uploadResult.format,
      size: uploadResult.bytes,
      duration: uploadResult.duration
    };
  } catch (error) {
    logger.error('❌ Cloudinary video upload failed:', error.message);
    throw new Error(`Video upload failed: ${error.message}`);
  }
};

// Delete file from Cloudinary
const deleteFile = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    logger.info(`✅ File deleted from Cloudinary: ${publicId}`);
    return result;
  } catch (error) {
    logger.error('❌ Cloudinary delete failed:', error.message);
    throw new Error(`Delete failed: ${error.message}`);
  }
};

// Get file info
const getFileInfo = async (publicId) => {
  try {
    const result = await cloudinary.api.resource(publicId);
    return result;
  } catch (error) {
    logger.error('❌ Cloudinary get file info failed:', error.message);
    throw new Error(`Get file info failed: ${error.message}`);
  }
};

export {
  cloudinary,
  testConnection,
  uploadFile,
  uploadVideo,
  deleteFile,
  getFileInfo
}; 