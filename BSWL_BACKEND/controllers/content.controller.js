import Content from '../models/content.model.js';
import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import { bucket } from '../config/firebase.js';
import { v4 as uuidv4 } from 'uuid';

export const createContent = asyncHandler(async (req, res) => {
  const { title, category, difficulty, englishDescription, quizzes } = req.body;
  
  // Create content without video first
  const content = await Content.create({
    title,
    category,
    difficulty,
    englishDescription,
    quizzes
  });
  
  res.status(201).json(content);
});

export const uploadVideo = asyncHandler(async (req, res) => {
  if (!req.file) {
    throw new httpErrors.BadRequest('No video file uploaded');
  }
  
  const { contentId } = req.params;
  const content = await Content.findById(contentId);
  if (!content) {
    throw new httpErrors.NotFound('Content not found');
  }
  
  // Generate unique filename
  const fileName = `videos/${uuidv4()}-${req.file.originalname}`;
  const file = bucket.file(fileName);
  
  // Upload to Firebase Storage
  await file.save(req.file.buffer, {
    metadata: {
      contentType: req.file.mimetype
    }
  });
  
  // Make file public
  await file.makePublic();
  
  // Save URL to content
  content.hindiSignVideo = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
  await content.save();
  
  res.json({ videoUrl: content.hindiSignVideo });
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
  
  // Delete associated video if exists
  if (content.hindiSignVideo) {
    const url = new URL(content.hindiSignVideo);
    const fileName = decodeURIComponent(url.pathname.split('/').pop());
    const file = bucket.file(fileName);
    
    try {
      await file.delete();
    } catch (error) {
      console.error('Failed to delete video:', error);
    }
  }
  
  res.status(204).send();
});