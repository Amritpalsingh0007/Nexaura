import ffmpeg from 'fluent-ffmpeg';
import path from 'path';
import fs from 'fs';

function generateHLS(inputPath, outputDir, resolution, uuid) {
    console.log("This is HLS Function")
    return new Promise((resolve, reject) => {
      const outputPath = path.join(outputDir, resolution, uuid);
      const playlistName = `${uuid}.m3u8`;
  
      // Ensure output directory exists
      fs.mkdirSync(outputPath, { recursive: true });
  
      ffmpeg(inputPath)
        .addOptions([
          '-profile:v baseline', // For H264 codec
          '-level 3.0',
          '-start_number 0',
          '-hls_time 5',
          '-hls_list_size 0',
          '-f hls'
        ])
        .audioCodec('aac')
        .output(path.join(outputPath, playlistName))
        .on('end', () => {
          console.log(`HLS generated for ${resolution}`);
          resolve(outputPath);
        })
        .on('error', (err) => reject(err))
        .run();
    });
  }


export default generateHLS;