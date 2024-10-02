import express from 'express';
import multer from 'multer';
import path from 'path';
import preprocessVideo from '../services/preprocessing';
import transcodeToResolutions from '../services/transcoding';

const router = express.Router();

// Set up storage engine
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, '../public/videos'); // Upload directory
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname)); // Unique filename
  }
});

const upload = multer({ storage: storage });

// Handle video upload
router.post('/upload', upload.single('video'), async (req, res) => {
    const filePath = req.file.path;
    const outputDir = path.dirname(filePath);
  
    try {
      const preprocessedPath = await preprocessVideo(filePath, outputDir);
      const transcodedPaths = await transcodeToResolutions(preprocessedPath, outputDir);
  
      const resolutions = ['1080p', '720p', '480p', '360p', '240p', '144p'];
      const hlsPromises = transcodedPaths.map((transcodedPath, index) => {
        const resolution = resolutions[index];
        return generateHLS(transcodedPath, outputDir, resolution);
      });
  
      await Promise.all(hlsPromises);
  
      res.json({ message: 'HLS generation successful' });
    } catch (error) {
      console.error('Error during HLS generation:', error);
      res.status(500).json({ error: 'HLS generation failed' });
    }
  });  

export default router;