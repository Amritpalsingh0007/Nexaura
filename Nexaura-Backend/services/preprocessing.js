import ffmpeg from 'fluent-ffmpeg';
import path from 'path';
import fs from 'fs';

function preprocessVideo(inputPath, outputDir, uuid) {
  console.log("\nThis is PreProcessing");
  return new Promise((resolve, reject) => {
    // Step 1: Get video info
    ffmpeg.ffprobe(inputPath, (err, metadata) => {
      if (err) return reject(err);

      const videoStream = metadata.streams.find(s => s.codec_type === 'video');
      const { width, height, codec_name } = videoStream;

      const needsConversion = codec_name !== 'h264' || height > 1080 || width > 1920;

      const outputPath = path.join(outputDir, `${uuid}.mp4`);

      if (needsConversion) {
        // Convert to H.264 and downscale to 1080p if necessary
        ffmpeg(inputPath)
          .videoCodec('libx264')
          .audioCodec('aac')
          .size('1920x1080') // Maintains aspect ratio, sets height to 1080
          .output(outputPath)
          .on('end', () => {
            console.log("Video processing finished");
            extractThumbnail(outputPath, outputDir, uuid)
              .then(() => resolve(outputPath))
              .catch(reject);
          })
          .on('error', (err) => reject(err))
          .run();
      } else {
        // No conversion needed
        extractThumbnail(inputPath, outputDir, uuid)
          .then(() => resolve(inputPath))
          .catch(reject);
      }
    });
  });
}

// Step 2: Extract a thumbnail from the video and save it as JPG
function extractThumbnail(videoPath, outputDir, uuid) {
  return new Promise((resolve, reject) => {
    const thumbnailPath = path.resolve(outputDir,'..',"images"); // Use .jpg instead of .png
    console.log("Thumbnail path : ", thumbnailPath)
    ffmpeg(videoPath)
      .screenshots({
        timestamps: ['1'], // Capture a frame at 1 second
        filename: `${uuid}.jpg`, // Use .jpg format
        folder: thumbnailPath,
        size: '1280x720' // Maintain aspect ratio
      })
      .on('end', () => {
        console.log(`Thumbnail saved at ${thumbnailPath}`);
        resolve(thumbnailPath);
      })
      .on('error', (err) => reject(err));
  });
}

export default preprocessVideo;
