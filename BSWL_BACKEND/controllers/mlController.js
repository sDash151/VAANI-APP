import asyncHandler from 'express-async-handler';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import mlService from '../services/mlService.js';
import logger from '../utils/logger.js';

// Configure multer for video uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = 'uploads/videos';
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 50 * 1024 * 1024, // 50MB limit
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['video/mp4', 'video/avi', 'video/mov', 'video/wmv', 'video/flv'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid video file type. Only MP4, AVI, MOV, WMV, FLV are allowed.'), false);
        }
    }
});

/**
 * @desc    Translate video to ISL
 * @route   POST /api/v1/ml/translate
 * @access  Private
 */
const translateVideo = asyncHandler(async (req, res) => {
    try {
        if (!req.file) {
            res.status(400);
            throw new Error('No video file uploaded');
        }

        const videoPath = req.file.path;
        logger.info(`Processing video translation for file: ${req.file.originalname}`);

        const result = await mlService.translateVideo(videoPath);

        if (!result.success) {
            res.status(500);
            throw new Error(result.error || 'Translation failed');
        }

        // Clean up uploaded file after processing
        fs.unlinkSync(videoPath);

        res.json({
            success: true,
            message: 'Video translated successfully',
            data: result.data
        });

    } catch (error) {
        // Clean up file if it exists
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        
        logger.error('Video translation error:', error.message);
        res.status(500);
        throw new Error(error.message);
    }
});

/**
 * @desc    Check ML service health
 * @route   GET /api/v1/ml/health
 * @access  Public
 */
const checkMLHealth = asyncHandler(async (req, res) => {
    const isHealthy = await mlService.checkHealth();
    
    res.json({
        success: true,
        data: {
            ml_service_healthy: isHealthy,
            timestamp: new Date().toISOString()
        }
    });
});

/**
 * @desc    Get ML service status
 * @route   GET /api/v1/ml/status
 * @access  Public
 */
const getMLStatus = asyncHandler(async (req, res) => {
    const status = await mlService.getStatus();
    
    if (!status.success) {
        res.status(503);
        throw new Error(status.error);
    }

    res.json({
        success: true,
        data: status.data
    });
});

export {
    translateVideo,
    checkMLHealth,
    getMLStatus,
    upload
}; 