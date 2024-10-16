import express from 'express';
import VideoModel from '../model/video_model.js'; 

const router = express.Router();

// Route to fetch video metadata with pagination
router.get('/', async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = 10; 
  const skip = (page - 1) * limit; 

  try {
    // Fetch the videos from the database, skip and limit for pagination
    const videos = await VideoModel.find().skip(skip).limit(limit); 

    let list = [];
    videos.forEach(video => {
      const uuid = video.videoUrl.replace(".mp4", '');
      list.push({ 
        uuid: uuid, 
        title: video.title, 
        objectId: video._id  
      });
    });

    res.json(list);
  } catch (err) {
    // Handle errors if the database query fails
    console.error("Error fetching videos:", err);
    res.status(500).json({ error: "Failed to fetch videos" });
  }
});

router.get('/metadata', async (req, res) => {
  const objectId = req.query.objectId;

  try {
    // Fetch the video metadata from the database using the objectId
    const video = await VideoModel.findById(objectId);

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    // Prepare the video metadata to send as JSON response
    const videoMetadata = {
      title: video.title,
      description: video.description,
      videoUrl: video.videoUrl,
      thumbnailUrl: video.thumbnailUrl,
      duration: video.duration,
      views: video.views,
      dislikes: video.dislikes,
      likes: video.likes,
      uploadDate: video.uploadDate.getTime(), // Convert Date to milliseconds
      uploaderId: video.uploaderId,
    };
    // Send the response back to the client
    res.json(videoMetadata);
  } catch (err) {
    console.error('Error fetching video metadata:', err);
    res.status(500).json({ error: 'Failed to fetch video metadata' });
  }
});

// Route to search videos by title or tags with word matching and priority sorting
router.get('/search', async (req, res) => {
  const query = req.query.query || ''; // Get the search query from the request
  const words = query.split(/\s+/).filter(Boolean); // Split query into words and filter out empty ones

  try {
    // Use regex to perform a case-insensitive search on both title and tags
    const videos = await VideoModel.find({
      $or: [
        { title: { $regex: query, $options: 'i' } }, // Case-insensitive title search
        { tags: { $in: words.map(word => new RegExp(word, 'i')) } } // Match words in tags
      ]
    });

    if (videos.length === 0) {
      return res.status(404).json({ message: 'No videos found' });
    }

    // Sort videos based on the number of matching words in the title and tags
    const prioritizedVideos = videos.map(video => {
      const titleMatches = words.filter(word =>
        new RegExp(word, 'i').test(video.title)
      ).length;

      const tagMatches = video.tags
        ? words.filter(word => video.tags.some(tag =>
            new RegExp(word, 'i').test(tag)
          )).length
        : 0;

      return {
        video,
        score: titleMatches + tagMatches, // Total score based on matches
      };
    });

    // Sort by score in descending order (higher score = more matches)
    prioritizedVideos.sort((a, b) => b.score - a.score);

    // Prepare response with the sorted videos
    const result = prioritizedVideos.map(({ video }) => ({
      uuid: video.videoUrl.replace('.mp4', ''),
      title: video.title,
      objectId: video._id,
    }));

    res.json(result);
  } catch (err) {
    console.error('Error fetching search results:', err);
    res.status(500).json({ error: 'Failed to fetch search results' });
  }
});


export default router;
