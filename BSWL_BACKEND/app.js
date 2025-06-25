import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';
import connectDB from './config/database.js';
import routes from './routes/index.js';
import { errorHandler } from './middlewares/error.middleware.js';
import { notFoundHandler } from './middlewares/error.middleware.js';
import { validationErrorHandler } from './middlewares/error.middleware.js';
import rateLimit from 'express-rate-limit';
import logger from './utils/logger.js';

const app = express();
const swaggerDocument = YAML.load('./swagger.yaml');

// Connect to MongoDB
connectDB();

// Security Middleware
app.use(cors());
app.use(helmet());

// Request Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
}

// Body Parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 🔥 Serve uploaded videos (e.g. /uploads/videos/xyz.mp4)
app.use('/uploads', express.static('uploads'));

// API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// API Routes
app.use('/api/v1', routes);

// Error Handling
app.use(validationErrorHandler);
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
