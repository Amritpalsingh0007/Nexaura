import mongoose from 'mongoose';

const videoSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, default: '' },
  videoUrl: { type: String, required: true },
  thumbnailUrl: { type: String, default: '', required: true},
  duration: { type: Number, required: true },
  views: { type: Number, default: 0 },
  likes: { type: Number, default: 0 },
  dislikes: { type: Number, default: 0 },
  tags: { type: [String], default: [] },
  fileSize: { type: Number, required: true },
  uploadDate: { type: Date, default: Date.now },
  uploaderId: {type: String, require: true}
});

// Create the model
const VideoModel = mongoose.model('Video', videoSchema);

export default VideoModel;
