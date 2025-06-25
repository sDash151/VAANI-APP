import mongoose from 'mongoose';
import logger from '../utils/logger.js';

const CONNECTION_RETRY_LIMIT = 5;
const INITIAL_RETRY_DELAY = 1000;
let retryCount = 0;

const connectDB = async () => {
  const mongoUri = process.env.MONGO_URI;
  const mongoUser = process.env.MONGO_USER;
  const mongoPassword = process.env.MONGO_PASSWORD;

  if (!mongoUri) {
    logger.error('❌ MongoDB connection failed: MONGO_URI not defined');
    process.exit(1);
  }

  const options = {
    autoIndex: process.env.NODE_ENV === 'development',
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
    heartbeatFrequencyMS: 30000,
    retryWrites: true,
    w: 'majority',
    authSource: 'admin',
  };

  if (mongoUser && mongoPassword) {
    options.auth = {
      username: mongoUser,
      password: mongoPassword,
    };
  }

  try {
    await mongoose.connect(mongoUri, options);
    logger.info('✅ MongoDB connected successfully');
    retryCount = 0;
  } catch (error) {
    retryCount++;

    logger.error(`❌ MongoDB connection failed (attempt ${retryCount}/${CONNECTION_RETRY_LIMIT}): ${error.message}`);

    if (error.message.includes('Authentication failed')) {
      logger.error('🔐 Authentication failure. Check credentials:');
      logger.error(`- MONGO_URI: ${mongoUri ? '✅' : '❌ missing'}`);
      logger.error(`- MONGO_USER: ${mongoUser ? '✅ set' : '❌ not set'}`);
      logger.error(`- MONGO_PASSWORD: ${mongoPassword ? '✅ set' : '❌ not set'}`);
    }

    if (retryCount < CONNECTION_RETRY_LIMIT) {
      const delay = INITIAL_RETRY_DELAY * Math.pow(2, retryCount);
      logger.info(`⏳ Retrying in ${Math.round(delay / 1000)}s...`);
      setTimeout(connectDB, delay);
    } else {
      logger.error('💥 FATAL: MongoDB connection failed after maximum retries');
      process.exit(1);
    }
  }
};

// MongoDB Event Listeners
mongoose.connection.on('connected', () => logger.info('📊 MongoDB connection established'));
mongoose.connection.on('disconnected', () => logger.warn('⚠️ MongoDB connection lost'));
mongoose.connection.on('reconnected', () => logger.info('🔁 MongoDB connection restored'));
mongoose.connection.on('error', (err) => logger.error(`❌ MongoDB error: ${err.message}`));

// Enable mongoose debug logs in development
if (process.env.NODE_ENV === 'development') {
  mongoose.set('debug', (collection, method, query, doc) => {
    logger.debug(`Mongoose ${collection}.${method}`, { query, doc });
  });
}

export default connectDB;
