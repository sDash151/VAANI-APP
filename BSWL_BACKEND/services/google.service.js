import { translateClient, bucketName } from '../config/google-cloud.js';

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

export const uploadFile = async (fileBuffer, fileName, contentType) => {
  const file = bucket.file(fileName);
  
  await file.save(fileBuffer, {
    metadata: {
      contentType: contentType
    }
  });
  
  await file.makePublic();
  
  return `https://storage.googleapis.com/${bucketName}/${fileName}`;
};

export const deleteFile = async (fileName) => {
  const file = bucket.file(fileName);
  await file.delete();
};