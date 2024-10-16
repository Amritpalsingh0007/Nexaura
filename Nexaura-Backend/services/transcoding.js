import path from 'path';
import ffmpeg from 'fluent-ffmpeg';

function transcodeToResolutions(inputPath, outputDir, uuid) {
  const resolutions = [
    { name: '1080p', width: 1920 },
    { name: '720p', width: 1280 },
    { name: '480p', width: 854 },
    { name: '360p', width: 640 },
    { name: '240p', width: 426 },
    { name: '144p', width: 256 },
  ];

  const transcodePromises = resolutions.map(resolution => {
    return new Promise((resolve, reject) => {
      // Create a unique output file path for each resolution
      const outputFilePath = path.join(outputDir, `${uuid}_${resolution.name}.mp4`);

      ffmpeg(inputPath)
        .videoCodec('libx264')
        .audioCodec('copy')
        .size(`${resolution.width}x?`) // Maintains aspect ratio
        .output(outputFilePath)
        .on('end', () => {
          console.log(`Transcoded to ${resolution.name}`);
          resolve(outputFilePath);
        })
        .on('error', (err) => reject(err))
        .run();
    });
  });

  return Promise.all(transcodePromises);
}

export default transcodeToResolutions;
