import Joi from 'joi';
import httpErrors from 'http-errors';

// Reusable schemas
const emailSchema = Joi.string().email().required();
const passwordSchema = Joi.string().min(6).required();
const objectIdSchema = Joi.string().pattern(/^[0-9a-fA-F]{24}$/);

// Validation middleware creator
export const validate = (schema, property = 'body') => {
  return (req, res, next) => {
    const { error } = schema.validate(req[property], {
      abortEarly: false,
      allowUnknown: true,
      stripUnknown: true
    });
    
    if (error) {
      const errors = {};
      error.details.forEach(detail => {
        errors[detail.path[0]] = detail.message;
      });
      
      throw new httpErrors.BadRequest('Validation error', { details: errors });
    }
    
    next();
  };
};

// Specific schemas
export const authSchemas = {
  register: Joi.object({
    email: emailSchema,
    password: passwordSchema
  }),
  
  login: Joi.object({
    email: emailSchema,
    password: Joi.string().required()
  }),
  
  googleLogin: Joi.object({
    idToken: Joi.string().required()
  }),
  
  refreshToken: Joi.object({
    refreshToken: Joi.string().required()
  })
};

export default {
  validateProgressUpdate: (req, res, next) => {
    const { lessonId, score } = req.body;
    
    if (!lessonId || typeof score !== 'number' || score < 0 || score > 100) {
      throw new httpErrors.BadRequest(
        'Invalid progress data. lessonId is required and score must be a number between 0-100'
      );
    }
    
    next();
  },
};

export const contentSchemas = {
  createContent: Joi.object({
    title: Joi.string().required(),
    category: Joi.string().valid('math', 'science', 'language').required(),
    difficulty: Joi.number().min(1).max(5).required(),
    englishDescription: Joi.string().required(),
    quizzes: Joi.array().items(
      Joi.object({
        question: Joi.string().required(),
        options: Joi.array().items(Joi.string()).min(2).required(),
        correctIndex: Joi.number().min(0).required()
      })
    )
  })
};

export const translationSchemas = {
  signToText: Joi.object({
    imageBase64: Joi.string().required()
  }),
  
  textToSign: Joi.object({
    text: Joi.string().required(),
    targetLanguage: Joi.string().valid('hindi', 'english').default('hindi')
  })
};

export const userSchemas = {
  updateProfile: Joi.object({
    'preferences.language': Joi.string().valid('english', 'hindi'),
    'preferences.notificationEnabled': Joi.boolean()
  }),
  
  updateProgress: Joi.object({
    lessonId: Joi.string().required(),
    score: Joi.number().min(0).max(100).required()
  })
};