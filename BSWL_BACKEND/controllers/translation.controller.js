import httpErrors from 'http-errors';
import asyncHandler from 'express-async-handler';
import { recognizeSign } from '../services/ml.service.js';
import { translateText } from '../config/google-cloud.js';

// signToText: uses req.user for language preference
export const signToText = asyncHandler(async (req, res) => {
  const { imageBase64 } = req.body;
  if (!imageBase64) {
    throw new httpErrors.BadRequest('Image data is required');
  }
  const result = await recognizeSign(imageBase64);
  // Use req.user.preferences if available, fallback to 'english'
  const user = req.user;
  const lang = user.preferences?.language || 'english';
  const translation = lang === 'hindi' ? result.hindi : result.english;
  res.json({ translation, confidence: result.confidence });
});

// textToSign: uses req.user for language preference
export const textToSign = asyncHandler(async (req, res) => {
  const { text, sourceLang, targetLang } = req.body;
  if (!text) {
    throw new httpErrors.BadRequest('Text input is required');
  }
  // Use user's preferred language if not provided
  const user = req.user;
  const finalTargetLang = targetLang || user.preferences?.language || 'hindi';
  const validLangs = ['hindi', 'english'];
  if (!validLangs.includes(finalTargetLang)) {
    throw new httpErrors.BadRequest('Invalid target language');
  }
  let processedText = text;
  if (sourceLang && sourceLang !== 'english') {
    processedText = await translateText(text, 'en');
  }
  // Generate sign language video (assume generateSignVideo exists)
  const video = await generateSignVideo(processedText, finalTargetLang);
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