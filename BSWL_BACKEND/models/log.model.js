import mongoose from 'mongoose';

const logSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true
  },
  action: {
    type: String,
    required: true,
    enum: ['login', 'logout', 'content_view', 'quiz_attempt', 'video_upload']
  },
  details: {
    type: mongoose.Schema.Types.Mixed
  },
  ipAddress: {
    type: String
  },
  userAgent: {
    type: String
  }
}, { 
  timestamps: true,
  capped: { size: 1024 * 1024 * 100, max: 100000 } // 100MB capped collection
});

// Auto-expire logs after 90 days
logSchema.index({ createdAt: 1 }, { expireAfterSeconds: 90 * 24 * 60 * 60 });

const ActivityLog = mongoose.model('ActivityLog', logSchema);

export default ActivityLog;