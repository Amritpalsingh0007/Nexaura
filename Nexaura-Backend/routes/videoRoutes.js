import express from 'express';
const router = express.Router();

router.get('/videos', (req, res) => {
  console.log("recieved a request!");
  const page = parseInt(req.query.page) || 1;
  const limit = 10;

  const videoData = Array.from({ length: limit }, (_, index) => {
    const uuid = `video-${(page - 1) * limit + index + 1}`; 
    return {
      uuid: uuid,
      title: `Video Title ${uuid}`,
    };
  });

  res.json(videoData);
});

export default router;
