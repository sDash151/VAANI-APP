import httpErrors from 'http-errors';
import winston from 'winston';

export const errorHandler = (err, req, res, next) => {
  // Log the error
  winston.error(`${err.status || 500} - ${err.message} - ${req.originalUrl} - ${req.method} - ${req.ip}`);
  
  // Check if error is operational (trusted)
  if (err.expose) {
    return res.status(err.status || 500).json({
      error: {
        message: err.message,
        status: err.status || 500,
        details: err.details || {}
      }
    });
  }
  
  // For programming errors, don't leak details
  res.status(500).json({
    error: {
      message: 'Internal Server Error',
      status: 500
    }
  });
};

export const notFoundHandler = (req, res, next) => {
  next(new httpErrors.NotFound(`Route not found: ${req.originalUrl}`));
};

export const validationErrorHandler = (err, req, res, next) => {
  if (err.name === 'ValidationError') {
    const errors = {};
    Object.keys(err.errors).forEach(key => {
      errors[key] = err.errors[key].message;
    });
    
    return res.status(400).json({
      error: {
        message: 'Validation failed',
        status: 400,
        details: errors
      }
    });
  }
  
  next(err);
};