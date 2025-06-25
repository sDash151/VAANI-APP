import mongoose from 'mongoose';

const quizSchema = new mongoose.Schema({
  question: { 
    type: String, 
    required: true 
  },
  options: [{ 
    type: String, 
    required: true 
  }],
  correctIndex: { 
    type: Number, 
    min: 0, 
    required: true 
  }
}, { _id: false });

const contentSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    index: true
  },
  category: {
    type: String,
    enum: ['math', 'science', 'language'],
    required: true
  },
  difficulty: {
    type: Number,
    min: 1,
    max: 5,
    default: 1
  },
  hindiSignVideo: {
    type: String,
    validate: {
      validator: v => typeof v === 'string' && v.trim() !== '',
      message: props => `${props.value} is not a valid video URL!`
    }
  },
  englishDescription: {
    type: String,
    required: true
  },
  quizzes: [quizSchema]
}, { timestamps: true });

const Content = mongoose.model('Content', contentSchema);

export default Content;
