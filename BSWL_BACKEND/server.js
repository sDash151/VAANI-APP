console.log('✅ Server starting...');
let app;
try {
  app = (await import('./app.js')).default;
} catch (err) {
  console.error('❌ Error while importing app.js:', err);
  process.exit(1);
}

import dotenv from 'dotenv';
import logger from './utils/logger.js';

dotenv.config();

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  logger.info(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error(`Unhandled Rejection: ${err.message}`);
  server.close(() => process.exit(1));
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
  });
});