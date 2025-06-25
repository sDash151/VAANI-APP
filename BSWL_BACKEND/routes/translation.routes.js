import express from 'express';
const router = express.Router();

import {
  signToText,
  textToSign
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

// ✅ Temporary GET Routes (for testing in Postman)
router.get('/test', (req, res) => {
  res.status(200).json({ message: 'Translate route is working!' });
});

router.get('/ping', (req, res) => {
  res.status(200).json({ message: 'pong 🏓' });
});

export default router;