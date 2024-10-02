import ffmpeg from 'fluent-ffmpeg';
import path from 'path';

function preprocessVideo(inputPath, outputDir) {
  return new Promise((resolve, reject) => {
    // Step 1: Get video info
    ffmpeg.ffprobe(inputPath, (err, metadata) => {
      if (err) return reject(err);

      const videoStream = metadata.streams.find(s => s.codec_type === 'video');
      const { width, height, codec_name } = videoStream;

      const needsConversion = codec_name !== 'h264' || height > 1080 || width > 1920;

      if (needsConversion) {
        // Convert to H.264 and downscale to 1080p if necessary
        const outputPath = path.join(outputDir, 'preprocessed.mp4');

        ffmpeg(inputPath)
          .videoCodec('libx264')
          .size('1920x1080') // Maintains aspect ratio, sets height to 1080
          .output(outputPath)
          .on('end', () => resolve(outputPath))
          .on('error', (err) => reject(err))
          .run();
      } else {
        // No conversion needed
        resolve(inputPath);
      }
    });
  });
}
export default preprocessVideo;