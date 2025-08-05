console.log('🌐 Loading Google Cloud Config...');
console.log('GOOGLE_CLOUD_CREDENTIAL:', process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON)

import { Storage } from '@google-cloud/storage';
import { TranslationServiceClient } from '@google-cloud/translate';
import fs from 'fs';
import logger from '../utils/logger.js';

// Initialize Google Cloud clients
let storage = null;
let translateClient = null;
let bucketName = null;

try {
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON) {
    logger.warn('GOOGLE_APPLICATION_CREDENTIALS_JSON not found. Google Cloud features will be disabled.');
  } else {
    let googleCredentials;
    const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON;
    
    logger.info(`Loading Google Cloud credentials from: ${credentialsPath}`);
    
    if (credentialsPath.endsWith('.json')) {
      if (!fs.existsSync(credentialsPath)) {
        throw new Error(`Credentials file not found: ${credentialsPath}`);
      }
      googleCredentials = JSON.parse(fs.readFileSync(credentialsPath, 'utf8'));
      logger.info('Google Cloud credentials loaded from JSON file');
    } else {
      googleCredentials = JSON.parse(credentialsPath);
      logger.info('Google Cloud credentials loaded from environment variable');
    }

    logger.info(`Initializing Google Cloud services for project: ${process.env.GOOGLE_CLOUD_PROJECT_ID}`);

    storage = new Storage({
      projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
      credentials: googleCredentials
    });

    translateClient = new TranslationServiceClient({
      projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
      credentials: googleCredentials
    });
    
    bucketName = process.env.GOOGLE_CLOUD_BUCKET_NAME;
    logger.info('Google Cloud services initialized successfully');
    logger.info(`Translation Service Client: ${translateClient ? 'Ready' : 'Failed'}`);
    logger.info(`Storage Client: ${storage ? 'Ready' : 'Failed'}`);
  }
} catch (error) {
  logger.error('Google Cloud initialization failed:', error);
  logger.warn('Running without Google Cloud features. Using fallback translation.');
  translateClient = null;
  storage = null;
}

export { storage, translateClient, bucketName };

// Google Translation helper
export const translateText = async (text, targetLanguage, sourceLanguage = 'en') => {
  try {
    // Always use fallback translation for now (free and reliable)
    logger.info(`Using fallback translation: "${text}" from ${sourceLanguage} to ${targetLanguage}`);
    return getFallbackTranslation(text, targetLanguage, sourceLanguage);
    
    // Uncomment below if you want to use Google Cloud later
    /*
    if (!translateClient) {
      logger.warn('Google Translate not configured. Using fallback translation.');
      return getFallbackTranslation(text, targetLanguage, sourceLanguage);
    }
    
    logger.info(`Translating from ${sourceLanguage} to ${targetLanguage}: "${text}"`);
    
    const [response] = await translateClient.translateText({
      parent: `projects/${process.env.GOOGLE_CLOUD_PROJECT_ID}/locations/global`,
      contents: [text],
      mimeType: 'text/plain',
      sourceLanguageCode: sourceLanguage,
      targetLanguageCode: targetLanguage,
    });

    const translatedText = response.translations[0].translatedText;
    logger.info(`Translation result: "${translatedText}"`);
    return translatedText;
    */
  } catch (error) {
    logger.error('Translation error:', error);
    logger.warn('Using fallback translation due to error.');
    return getFallbackTranslation(text, targetLanguage, sourceLanguage);
  }
};

// Fallback translation for common phrases
const getFallbackTranslation = (text, targetLanguage, sourceLanguage) => {
  const commonTranslations = {
    'en-hi': {
      'hello': 'नमस्ते',
      'hi': 'नमस्ते',
      'good morning': 'सुप्रभात',
      'good afternoon': 'नमस्कार',
      'good evening': 'शुभ संध्या',
      'thank you': 'धन्यवाद',
      'please': 'कृपया',
      'sorry': 'माफ़ करें',
      'yes': 'हाँ',
      'no': 'नहीं',
      'water': 'पानी',
      'food': 'खाना',
      'help': 'मदद',
      'name': 'नाम',
      'how are you': 'कैसे हो आप',
      'i am fine': 'मैं ठीक हूँ',
      'goodbye': 'अलविदा',
      'welcome': 'स्वागत है',
      'good': 'अच्छा',
      'bad': 'बुरा',
      'love': 'प्यार',
      'family': 'परिवार',
      'friend': 'दोस्त',
      'school': 'स्कूल',
      'work': 'काम',
      'home': 'घर',
      'time': 'समय',
      'day': 'दिन',
      'night': 'रात',
    },
    'en-es': {
      'hello': 'hola',
      'hi': 'hola',
      'good morning': 'buenos días',
      'good afternoon': 'buenas tardes',
      'good evening': 'buenas noches',
      'thank you': 'gracias',
      'please': 'por favor',
      'sorry': 'lo siento',
      'yes': 'sí',
      'no': 'no',
      'good': 'bueno',
      'bad': 'malo',
      'love': 'amor',
      'family': 'familia',
      'friend': 'amigo',
      'school': 'escuela',
      'work': 'trabajo',
      'home': 'casa',
      'time': 'tiempo',
      'day': 'día',
      'night': 'noche',
    }
  };

  const key = `${sourceLanguage}-${targetLanguage}`;
  const translations = commonTranslations[key] || {};
  const lowerText = text.toLowerCase().trim();
  
  if (translations[lowerText]) {
    logger.info(`Fallback translation found: "${text}" -> "${translations[lowerText]}"`);
    return translations[lowerText];
  }
  
  logger.warn(`No fallback translation found for: "${text}" (${sourceLanguage} -> ${targetLanguage})`);
  return text; // Return original text if no translation found
};