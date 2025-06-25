// utils/validators/user.validator.js
import Joi from 'joi';

export const userUpdateSchema = Joi.object({
  name: Joi.string().min(2).max(50),
  email: Joi.string().email(),
  profilePicture: Joi.string().uri(),
  learningProgress: Joi.object(),
  preferences: Joi.object({
    theme: Joi.string().valid('light', 'dark'),
    notificationFrequency: Joi.string().valid('daily', 'weekly', 'never')
  })
});