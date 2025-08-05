import express from 'express';
const router = express.Router();

import {
  signToText,
  textToSign,
  translateTextRoute
} from '../controllers/translation.controller.js';

import { authenticate } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';
import { translationSchemas } from '../middlewares/validation.middleware.js';

// 🔒 POST Routes (Protected)
router.post(
  '/sign-to-text',
  authenticate,
  validate(translationSchemas.signToText),
  signToText
);

router.post(
  '/text-to-sign',
  authenticate,
  validate(translationSchemas.textToSign),
  textToSign
);

// Google Translation Route
router.post(
  '/google-translate',
  authenticate,
  translateTextRoute
);

// ✅ Temporary GET Routes (for testing in Postman)
router.get('/test', (req, res) => {
  res.status(200).json({ message: 'Translate route is working!' });
});

router.get('/ping', (req, res) => {
  res.status(200).json({ message: 'pong 🏓' });
});

// Test translation endpoint (no auth required for testing)
router.post('/test-translate', async (req, res) => {
  try {
    const { text, sourceLang, targetLang } = req.body;
    console.log('Test translation request:', { text, sourceLang, targetLang });
    
    if (!text || !sourceLang || !targetLang) {
      return res.status(400).json({ 
        error: 'Missing required parameters: text, sourceLang, targetLang' 
      });
    }
    
    const { translateText } = await import('../config/google-cloud.js');
    const translation = await translateText(text, targetLang, sourceLang);
    
    res.json({ 
      success: true,
      translation,
      originalText: text,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang
    });
  } catch (error) {
    console.error('Test translation failed:', error);
    res.status(500).json({ 
      success: false,
      error: error.message 
    });
  }
});

export default router;