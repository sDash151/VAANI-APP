import { recognizeSign, generateSignVideo } from './ml.service.js';
import { translateText } from './google.service.js';

export const processSignToText = async (imageBase64, targetLanguage = 'en') => {
  const recognitionResult = await recognizeSign(imageBase64);
  
  if (targetLanguage === 'hi') {
    return recognitionResult.hindi;
  }
  
  return recognitionResult.english;
};

export const processTextToSign = async (text, targetLanguage = 'hindi') => {
  // Translate text to English if needed for sign generation
  let processedText = text;
  if (targetLanguage === 'hindi') {
    processedText = await translateText(text, 'en');
  }
  
  return await generateSignVideo(processedText, targetLanguage);
};

export const translateContent = async (content, targetLanguage) => {
  const translatedContent = { ...content };
  
  if (targetLanguage === 'hi') {
    translatedContent.title = await translateText(content.title, 'hi');
    translatedContent.description = await translateText(content.description, 'hi');
    
    // Translate quiz questions and options
    if (content.quizzes) {
      for (const quiz of translatedContent.quizzes) {
        quiz.question = await translateText(quiz.question, 'hi');
        quiz.options = await Promise.all(
          quiz.options.map(option => translateText(option, 'hi'))
        );
      }
    }
  }
  
  return translatedContent;
};