console.log('🌐 Loading Google Cloud Config...');
console.log('GOOGLE_CLOUD_CREDENTIAL:', process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON)
import { Storage } from '@google-cloud/storage';
import { TranslationServiceClient } from '@google-cloud/translate';
import fs from 'fs';

// Initialize Google Cloud clients
let googleCredentials;
if (process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON.endsWith('.json')) {
  googleCredentials = JSON.parse(fs.readFileSync(process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON, 'utf8'));
} else {
  googleCredentials = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON);
}

export const storage = new Storage({
  projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
  credentials: googleCredentials
});

export const translateClient = new TranslationServiceClient();

export const bucketName = process.env.GOOGLE_CLOUD_BUCKET_NAME;

// Google Translation helper
export const translateText = async (text, targetLanguage) => {
  try {
    const [response] = await translateClient.translateText({
      parent: `projects/${process.env.GOOGLE_CLOUD_PROJECT_ID}/locations/global`,
      contents: [text],
      mimeType: 'text/plain',
      sourceLanguageCode: 'en',
      targetLanguageCode: targetLanguage,
    });

    return response.translations[0].translatedText;
  } catch (error) {
    console.error('Translation error:', error);
    throw new Error('Failed to translate text');
  }
};