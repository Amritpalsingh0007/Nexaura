import express from "express";
import userModel from "../model/user_model.js";
import videoModel from "../model/video_model.js";

const router = express.Router();

router.post("/history", async (req, res) => {
  const { userId, videoId } = req.body; // userId is Firebase UID

  try {
    let user = await userModel.findById(userId);

    if (!user) {
      // If user doesn't exist, create a new one
      user = new userModel({
        _id: userId,
        history: [videoId],
      });
      await user.save();
    } else {
      // If user exists, first remove the video if it exists, then add it to the end
      await userModel.updateOne(
        { _id: userId },
        { $pull: { history: videoId } } // Remove the video if it exists
      );

      await userModel.updateOne(
        { _id: userId },
        { $push: { history: videoId } } // Add the video to the end
      );
    }

    res.status(200).json({ message: "History updated" });
  } catch (error) {
    console.error("Error updating history:", error);
    res.status(500).json({ error: "Failed to update history" });
  }
});

router.post("/like", async (req, res) => {
  console.log("got a request");
  const { userId, videoId } = req.body;

  try {
    await userModel.updateOne(
      { _id: userId },
      {
        $addToSet: { likedvideos: videoId },
        $pull: { dislikedvideos: videoId },
      }
    );
    console.log("request done");

    res.status(200).json({ message: "Video liked" });
  } catch (error) {
    console.error("Error liking video:", error);
    res.status(500).json({ error: "Failed to like video" });
  }
});

router.post("/dislike", async (req, res) => {
  const { userId, videoId } = req.body;

  try {
    await userModel.updateOne(
      { _id: userId },
      {
        $addToSet: { dislikedvideos: videoId },
        $pull: { likedvideos: videoId },
      }
    );

    res.status(200).json({ message: "Video disliked" });
  } catch (error) {
    console.error("Error disliking video:", error);
    res.status(500).json({ error: "Failed to dislike video" });
  }
});


router.post("/likevideo", async (req, res) => {
    const { userId, page } = req.body;
    const limit = 10;
    const skip = (page - 1) * limit;
  
    try {
      // Fetch the user to get the liked videos
      const user = await userModel.findById(userId);
  
      if (!user || !user.likedvideos || user.likedvideos.length === 0) {
        return res.status(404).json({ message: "No liked videos found" });
      }

      console.log("USER Video IDS : ", user.likedvideos.toString());
      // Fetch the liked videos using the video IDs from likedVideos array
      const videos = await videoModel
        .find({ _id: { $in: user.likedvideos } })
        .skip(skip)
        .limit(limit);
  
      // Create a list of formatted video objects
      const list = videos.map((video) => ({
        uuid: video.videoUrl.replace(".mp4", ""),
        title: video.title,
        objectId: video._id,
      }));
  
      res.status(200).json(list);
    } catch (err) {
      console.error("Error fetching liked videos:", err);
      res.status(500).json({ error: "Failed to fetch liked videos" });
    }
  });


  router.post("/historyvideo", async (req, res) => {
    const { userId, page } = req.body;
    const limit = 10;
    const skip = (page - 1) * limit;
  
    try {
      // Fetch the user to get the liked videos
      const user = await userModel.findById(userId);
  
      if (!user || !user.history || user.likedvideos.length === 0) {
        return res.status(404).json({ message: "No liked videos found" });
      }

      // Fetch the liked videos using the video IDs from likedVideos array
      const videos = await videoModel
        .find({ _id: { $in: user.history} })
        .skip(skip)
        .limit(limit);
  
      // Create a list of formatted video objects
      const list = videos.map((video) => ({
        uuid: video.videoUrl.replace(".mp4", ""),
        title: video.title,
        objectId: video._id,
      }));
  
      res.status(200).json(list);
    } catch (err) {
      console.error("Error fetching liked videos:", err);
      res.status(500).json({ error: "Failed to fetch liked videos" });
    }
  });


export default router;
