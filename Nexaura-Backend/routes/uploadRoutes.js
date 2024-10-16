import express from 'express';
import multer from 'multer';
import path from 'path';
import preprocessVideo from '../services/preprocessing.js';
import transcodeToResolutions from '../services/transcoding.js';
import generateHLS from '../services/hlsSegmentation.js';
import { v4 as uuidv4 } from 'uuid'; // Using ES6 syntax
import VideoModel from '../model/video_model.js'; // Mongoose video model
import ffmpeg from 'fluent-ffmpeg'; // For metadata extraction
import { fileURLToPath } from 'url'; // For ESM support
import { dirname } from 'path'; // To get the directory name

const router = express.Router();

// Create __dirname for ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Set up storage engine
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, '../public/videos')); // Upload directory
  },
  filename: function (req, file, cb) {
    cb(null, `multer_created.mp4`); // Use UUID as filename with .mp4 extension
  }
});

const upload = multer({ storage: storage });

// Handle video upload
router.post('/', upload.single('video'), async (req, res) => {
  const uuid = uuidv4(); // Generate UUID
  const filePath = req.file.path;
  const outputDir = path.dirname(filePath);

  try {
    // Step 1: Preprocess the video (convert to H.264 if needed)
    const preprocessedPath = await preprocessVideo(filePath, outputDir, uuid);

    // Step 2: Transcode video to different resolutions
    const transcodedPaths = await transcodeToResolutions(preprocessedPath, outputDir, uuid);

    // Step 3: Generate HLS segments for each resolution
    const resolutions = ['1080p', '720p', '480p', '360p', '240p', '144p'];
    const hlsPromises = transcodedPaths.map((transcodedPath, index) => {
      const resolution = resolutions[index];
      return generateHLS(transcodedPath, outputDir, resolution, uuid);
    });

    await Promise.all(hlsPromises); // Wait for all resolutions to be generated

    // Step 4: Get video metadata (duration, codec, etc.)
    const metadata = await getVideoMetadata(preprocessedPath);

    // Step 5: Save metadata and video info in MongoDB
    const videoEntry = new VideoModel({
      title: req.body.title || 'Untitled Video',
      description: req.body.description || '',
      videoUrl: `${uuid}.mp4`,
      thumbnailUrl: `${uuid}.jpg`,
      duration: metadata.duration, // Duration from metadata
      fileSize: metadata.fileSize, // File size from metadata
      uploadDate: new Date(),
      tags: req.body.tags || [],
      uploaderId: req.body.uploaderId // Assuming uploader ID is passed in the request body
    });

    await videoEntry.save(); // Save the video entry to MongoDB
    console.log("Data uploaded to db");

    res.json({
      message: 'Video uploaded, transcoded, and HLS generated successfully',
      videoId: videoEntry._id
    });
  } catch (error) {
    console.error('Error during video processing:', error);
    res.status(500).json({ error: 'Video processing failed', details: error.message });
  }
});

// Function to get video metadata
function getVideoMetadata(filePath) {
  return new Promise((resolve, reject) => {
    ffmpeg.ffprobe(filePath, (err, metadata) => {
      if (err) {
        return reject(err);
      }
      const videoStream = metadata.streams.find(stream => stream.codec_type === 'video');
      if (!videoStream) {
        return reject(new Error('No video stream found'));
      }
      const { duration } = videoStream;
      resolve({
        duration,
        fileSize: metadata.format.size,
      });
    });
  });
}

export default router;
