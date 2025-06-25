import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import { recognizeSign } from '../services/ml.service.js';
import { translateText } from '../config/google-cloud.js';

export const signToText = asyncHandler(async (req, res) => {
  const { imageBase64 } = req.body;
  if (!imageBase64) {
    throw new httpErrors.BadRequest('Image data is required');
  }

  const result = await recognizeSign(imageBase64);
  
  // Return based on user's preferred language
  const user = req.user;
  const translation = user.preferences.language === 'hindi' ? 
    result.hindi : result.english;
  
  res.json({ translation, confidence: result.confidence });
});

export const textToSign = asyncHandler(async (req, res) => {
  const { text, sourceLang, targetLang = 'hindi' } = req.body;
  if (!text) {
    throw new httpErrors.BadRequest('Text input is required');
  }

  // Validate languages
  const validLangs = ['hindi', 'english'];
  if (!validLangs.includes(targetLang)) {
    throw new httpErrors.BadRequest('Invalid target language');
  }

  // Translate if needed
  let processedText = text;
  if (sourceLang && sourceLang !== 'english') {
    processedText = await translateText(text, 'en');
  }

  // Generate sign language video
  const video = await generateSignVideo(processedText, targetLang);
  res.json(video);
});

export const translateTextRoute = asyncHandler(async (req, res) => {
  const { text, sourceLang, targetLang } = req.body;
  
  if (!text || !sourceLang || !targetLang) {
    throw new httpErrors.BadRequest('Missing required parameters');
  }

  const translation = await translateText(text, targetLang);
  res.json({ translation });
});