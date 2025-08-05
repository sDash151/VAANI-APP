import axios from 'axios';
import logger from '../utils/logger.js';

// LibreTranslate - Free Translation Service
const LIBRE_TRANSLATE_URL = 'https://libretranslate.de/translate';
const LIBRE_LANGUAGES_URL = 'https://libretranslate.de/languages';

export const translateWithLibreTranslate = async (text, targetLanguage, sourceLanguage = 'en') => {
  try {
    logger.info(`LibreTranslate: Translating "${text}" from ${sourceLanguage} to ${targetLanguage}`);
    
    const response = await axios.post(LIBRE_TRANSLATE_URL, {
      q: text,
      source: sourceLanguage,
      target: targetLanguage,
      format: 'text'
    }, {
      timeout: 15000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    logger.info('LibreTranslate response status:', response.status);
    logger.info('LibreTranslate response data:', JSON.stringify(response.data, null, 2));

    if (response.data && response.data.translatedText) {
      logger.info(`LibreTranslate result: "${response.data.translatedText}"`);
      return response.data.translatedText;
    } else {
      throw new Error(`Invalid response from LibreTranslate: ${JSON.stringify(response.data)}`);
    }
  } catch (error) {
    if (error.response) {
      logger.error('LibreTranslate HTTP error:', error.response.status, error.response.data);
      throw new Error(`LibreTranslate HTTP error: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
    } else if (error.request) {
      logger.error('LibreTranslate network error:', error.message);
      throw new Error(`LibreTranslate network error: ${error.message}`);
    } else {
      logger.error('LibreTranslate error:', error.message);
      throw error;
    }
  }
};

// Get supported languages from LibreTranslate
export const getLibreTranslateLanguages = async () => {
  try {
    const response = await axios.get(LIBRE_LANGUAGES_URL, {
      timeout: 10000,
      headers: {
        'Accept': 'application/json'
      }
    });
    return response.data;
  } catch (error) {
    logger.error('Error fetching LibreTranslate languages:', error.message);
    return [];
  }
}; 