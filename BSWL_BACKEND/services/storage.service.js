import multer from 'multer';
import { storage } from '../config/google-cloud.js';
import { v4 as uuidv4 } from 'uuid';

// Configure multer memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only video files are allowed!'), false);
    }
  }
});

export default upload ;

export const uploadToFirebase = async (file, pathPrefix = 'uploads') => {
  if (!file) {
    throw new Error('No file provided');
  }
  
  const fileName = `${pathPrefix}/${uuidv4()}-${file.originalname}`;
  const bucketFile = storage.bucket().file(fileName);
  
  await bucketFile.save(file.buffer, {
    metadata: {
      contentType: file.mimetype
    }
  });
  
  await bucketFile.makePublic();
  
  return {
    publicUrl: `https://storage.googleapis.com/${storage.bucket().name}/${fileName}`,
    fileName
  };
};

export const deleteFromFirebase = async (fileName) => {
  const file = storage.bucket().file(fileName);
  await file.delete();
};