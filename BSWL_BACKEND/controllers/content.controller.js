import Content from '../models/content.model.js';
import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import { uploadVideo, deleteFile } from '../config/cloudinary.js';
import { v4 as uuidv4 } from 'uuid';
import logger from '../utils/logger.js';

// Optionally, you can restrict content creation to authenticated users (req.user)
export const createContent = asyncHandler(async (req, res) => {
  const { title, category, difficulty, englishDescription, quizzes } = req.body;
  // Optionally, associate content with req.user.uid if needed
  const content = await Content.create({
    title,
    category,
    difficulty,
    englishDescription,
    quizzes,
    // createdBy: req.user.uid // Uncomment if you want to track creator
  });
  res.status(201).json(content);
});

export const uploadContentVideo = asyncHandler(async (req, res) => {
  if (!req.file) {
    throw new httpErrors.BadRequest('No video file uploaded');
  }
  
  const { contentId } = req.params;
  const content = await Content.findById(contentId);
  if (!content) {
    throw new httpErrors.NotFound('Content not found');
  }
  
  try {
    // Upload video to Cloudinary
    const uploadResult = await uploadVideo(req.file, 'bswl/content-videos');
    
    // Update content with video URL
    content.hindiSignVideo = uploadResult.url;
    content.videoPublicId = uploadResult.public_id; // Store for future deletion
    await content.save();
    
    res.json({ 
      videoUrl: content.hindiSignVideo,
      publicId: uploadResult.public_id,
      size: uploadResult.size,
      duration: uploadResult.duration
    });
  } catch (error) {
    logger.error('Video upload failed:', error);
    throw new httpErrors.InternalServerError('Failed to upload video');
  }
});

export const getContent = asyncHandler(async (req, res) => {
  const { category, difficulty } = req.query;
  const filter = {};
  if (category) filter.category = category;
  if (difficulty) filter.difficulty = parseInt(difficulty);
  const content = await Content.find(filter);
  res.json(content);
});

export const updateContent = asyncHandler(async (req, res) => {
  const { id } = req.params;
  // Optionally, check if req.user.uid === content.createdBy for ownership
  const content = await Content.findByIdAndUpdate(id, req.body, { new: true });
  if (!content) {
    throw new httpErrors.NotFound('Content not found');
  }
  res.json(content);
});

export const deleteContent = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const content = await Content.findByIdAndDelete(id);
  if (!content) {
    throw new httpErrors.NotFound('Content not found');
  }
  
  // Delete associated video from Cloudinary if exists
  if (content.videoPublicId) {
    try {
      await deleteFile(content.videoPublicId);
      logger.info(`Video deleted from Cloudinary: ${content.videoPublicId}`);
    } catch (error) {
      logger.error('Failed to delete video from Cloudinary:', error);
      // Don't fail the request if video deletion fails
    }
  }
  
  res.status(204).send();
});