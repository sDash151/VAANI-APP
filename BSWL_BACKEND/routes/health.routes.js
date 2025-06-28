import express from 'express';
const router = express.Router();

// Health check route
router.get('/', (req, res) => {
  res.status(200).json({ message: 'Backend is working!' });
});

export default router;
