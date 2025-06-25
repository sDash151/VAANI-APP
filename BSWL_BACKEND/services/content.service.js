import Content from '../models/content.model.js';
import ActivityLog from '../models/log.model.js';

export const createContent = async (contentData) => {
  return await Content.create(contentData);
};

export const getContent = async (filters = {}) => {
  return await Content.find(filters);
};

export const getContentById = async (id) => {
  return await Content.findById(id);
};

export const updateContent = async (id, updateData) => {
  return await Content.findByIdAndUpdate(id, updateData, { new: true, runValidators: true });
};

export const deleteContent = async (id) => {
  const content = await Content.findByIdAndDelete(id);
  
  if (!content) {
    throw new Error('Content not found');
  }
  
  return content;
};

export const logContentActivity = async (userId, contentId, action) => {
  await ActivityLog.create({
    userId,
    action,
    details: { contentId }
  });
};

export const getContentWithProgress = async (userId) => {
  const user = await User.findById(userId);
  const content = await Content.find();
  
  return content.map(item => {
    const progress = user.progress.get(item._id.toString()) || 0;
    return {
      ...item.toObject(),
      userProgress: progress
    };
  });
};