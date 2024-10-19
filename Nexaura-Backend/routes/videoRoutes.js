import express from 'express';
import VideoModel from '../model/video_model.js'; 
import userModel from '../model/user_model.js';

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
  const query = req.query.query || ''; 
  const words = query.split(/\s+/).filter(Boolean); // Split query into words and filter out empty ones
  const page = parseInt(req.query.page) || 1; 
  const limit = 10; 
  const skip = (page - 1) * limit; 

  try {
    // Use regex to perform a case-insensitive search on both title and tags
    const videos = await VideoModel.find({
      $or: [
        { title: { $regex: query, $options: 'i' } }, 
        { tags: { $in: words.map(word => new RegExp(word, 'i')) } } 
      ]
    })
    .skip(skip)
    .limit(limit); 

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

    res.json(list); // Return the list of videos in the specified format
  } catch (err) {
    console.error('Error fetching search results:', err);
    res.status(500).json({ error: 'Failed to fetch search results' });
  }
});


router.patch('/increment-views', async (req, res) => {
  const {objectId} = req.body;
  try {
    const result = await VideoModel.findByIdAndUpdate(objectId,{ $inc: {views: 1} });
    if (result.modifiedCount === 0) {
      return res.status(404).json({ message: 'Video not found or no changes made' });
    }
    res.status(200).json({ message: 'Update successful' });
  } catch (error) {
    console.error('Error updating video:', error);
    res.status(500).json({ error: 'Failed to update video' });
  }
});

// Increment likes
router.post('/increment-likes', async (req, res) => {
  console.log("Just got inc like req!");
  const { objectId } = req.body;
  try {
    await VideoModel.findByIdAndUpdate(objectId, { $inc: { likes: 1 } });
    res.status(200).send({ message: 'Likes incremented' });
  } catch (error) {
    console.log("Unable to increment likes : ", error);
    res.status(500).send({ error: 'Failed to increment likes' });
  }
});

// Decrement likes
router.post('/decrement-likes', async (req, res) => {
  console.log("Just got dec like req!");

  const { objectId } = req.body;
  try {
    await VideoModel.findByIdAndUpdate(objectId, { $inc: { likes: -1 } });
    res.status(200).send({ message: 'Likes decremented' });
  } catch (error) {
    res.status(500).send({ error: 'Failed to decrement likes' });
  }
});

// Increment dislikes
router.post('/increment-dislikes', async (req, res) => {
  console.log("Just got inc dislike req!");

  const { objectId } = req.body;
  try {
    await VideoModel.findByIdAndUpdate(objectId, { $inc: { dislikes: 1 } });
    res.status(200).send({ message: 'Dislikes incremented' });
  } catch (error) {

    res.status(500).send({ error: 'Failed to increment dislikes' });
  }
});

// Decrement dislikes
router.post('/decrement-dislikes', async (req, res) => {
  console.log("Just got dec dislike req!");

  const { objectId } = req.body;
  try {
    await VideoModel.findByIdAndUpdate(objectId, { $inc: { dislikes: -1 } });
    res.status(200).send({ message: 'Dislikes decremented' });
  } catch (error) {
    res.status(500).send({ error: 'Failed to decrement dislikes' });
  }
});

router.post('/status', async (req, res) => {
  const { objectId, userId } = req.body;

  if (!objectId || !userId) {
    return res.status(400).json({ error: 'Invalid request data' });
  }

  try {
    const user = await userModel.findById(userId);

    if (!user) {
      return res.status(200).json({ isLiked: false, isDisliked: false });
    }

    const isLiked = user.likedvideos.includes(objectId);
    const isDisliked = user.dislikedvideos.includes(objectId);

    res.status(200).json({ isLiked, isDisliked });
  } catch (error) {
    console.error('Error checking like/dislike status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});


export default router;