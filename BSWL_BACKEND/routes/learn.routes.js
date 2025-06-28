import express from 'express';
import { authenticate } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Dummy data for demonstration
const subjects = [
  { name: 'English', icon: 'font_download' },
  { name: 'Maths', icon: 'calculate' },
  { name: 'Social Studies', icon: 'group' },
  { name: 'Science', icon: 'science' },
  { name: 'Hindi', icon: 'book' },
];

// Require authentication for all endpoints in this router
router.use(authenticate);

router.get('/subjects', (req, res) => {
  res.json({ subjects });
});

// Add more endpoints for lessons, progress, achievements as needed

export default router;
