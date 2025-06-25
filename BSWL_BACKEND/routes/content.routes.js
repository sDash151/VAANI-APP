import express from 'express';
import { 
  createContent, 
  getContent, 
  updateContent, 
  deleteContent,
  uploadVideo
} from '../controllers/content.controller.js';
import { validate, contentSchemas } from '../middlewares/validation.middleware.js';
import { authenticate, authorize, handleTokenRefresh } from '../middlewares/auth.middleware.js';
import upload from '../services/storage.service.js';

const router = express.Router();

// 🔒 Authenticate all routes
router.use(authenticate);

// Routes
router.post('/', validate(contentSchemas.createContent), createContent);
router.get('/', getContent);
router.put('/:id', updateContent);
router.delete('/:id', deleteContent);
router.post('/:contentId/upload-video', upload.single('video'), uploadVideo);

export default router;
