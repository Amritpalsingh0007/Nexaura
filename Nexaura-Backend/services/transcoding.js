function transcodeToResolutions(inputPath, outputDir) {
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
        const outputPath = path.join(outputDir, `${resolution.name}.mp4`);
  
        ffmpeg(inputPath)
          .videoCodec('libx264')
          .size(`${resolution.width}x?`) // Maintains aspect ratio
          .output(outputPath)
          .on('end', () => {
            console.log(`Transcoded to ${resolution.name}`);
            resolve(outputPath);
          })
          .on('error', (err) => reject(err))
          .run();
      });
    });
  
    return Promise.all(transcodePromises);
  }
  

export default transcodeToResolutions;