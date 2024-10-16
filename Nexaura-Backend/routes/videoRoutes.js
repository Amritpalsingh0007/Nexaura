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

router.get('/search', async (req, res) => {
  const query = req.query.query || ''; // Get the search query from the request
  const words = query.split(/\s+/).filter(Boolean); // Split query into words and filter out empty ones
  const page = parseInt(req.query.page) || 1; // Current page number
  const limit = 10; // Number of items per page
  const skip = (page - 1) * limit; // Calculate how many items to skip

  try {
    // Use regex to perform a case-insensitive search on both title and tags
    const videos = await VideoModel.find({
      $or: [
        { title: { $regex: query, $options: 'i' } }, // Case-insensitive title search
        { tags: { $in: words.map(word => new RegExp(word, 'i')) } } // Match words in tags
      ]
    })
    .skip(skip) // Apply pagination
    .limit(limit); // Limit the results

    if (videos.length === 0) {
      return res.status(404).json({ message: 'No videos found' });
    }

    // Prepare the response in the specified format
    let list = [];
    videos.forEach(video => {
      const uuid = video.videoUrl.replace('.mp4', '');
      list.push({ 
        uuid: uuid, 
        title: video.title, 
        objectId: video._id  
      });
    });

    console.log("search result : ",list);
    res.json(list); // Return the list of videos in the specified format
  } catch (err) {
    console.error('Error fetching search results:', err);
    res.status(500).json({ error: 'Failed to fetch search results' });
  }
});


router.patch('/update', async (req, res) => {
  const updates = req.body;
  try {
    const result = await VideoModel.updateOne(
      { _id: updates.objectId },  
      { $set: updates }
    );
    if (result.modifiedCount === 0) {
      return res.status(404).json({ message: 'Video not found or no changes made' });
    }
    res.status(200).json({ message: 'Update successful' });
  } catch (error) {
    console.error('Error updating video:', error);
    res.status(500).json({ error: 'Failed to update video' });
  }
});

export default router;
