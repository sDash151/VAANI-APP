import mongoose from 'mongoose';

const preferenceSchema = new mongoose.Schema({
  language: {
    type: String,
    enum: ['english', 'hindi'],
    default: 'english'
  },
  notificationEnabled: {
    type: Boolean,
    default: true
  }
}, { _id: false });

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false
  },
  progress: {
    type: Map,
    of: Number, // Score for each lesson
    default: {}
  },
  overallProgress: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  preferences: {
    type: preferenceSchema,
    default: () => ({})
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  lastLogin: Date,
  refreshTokens: [String],
  uid: {
    type: String,
    unique: true,
    sparse: true // Allows null for legacy users
  },
  fullName: {
    type: String,
    trim: true
  },
  photoUrl: {
    type: String
  }
}, { 
  timestamps: true,
  toJSON: { 
    virtuals: true,
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.refreshTokens;
      return ret;
    }
  }
});

// Virtual for completed lessons count
userSchema.virtual('completedLessons').get(function() {
  return this.progress.size;
});

const User = mongoose.model('User', userSchema);

export default User;