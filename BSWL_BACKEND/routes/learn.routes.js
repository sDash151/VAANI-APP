import express from 'express';
const router = express.Router();

// Dummy data for demonstration
const subjects = [
  { name: 'English', icon: 'font_download' },
  { name: 'Maths', icon: 'calculate' },
  { name: 'Social Studies', icon: 'group' },
  { name: 'Science', icon: 'science' },
  { name: 'Hindi', icon: 'book' },
];

router.get('/subjects', (req, res) => {
  res.json({ subjects });
});

// Add more endpoints for lessons, progress, achievements as needed

export default router;
