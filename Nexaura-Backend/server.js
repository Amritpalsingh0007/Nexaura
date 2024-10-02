import express from 'express';
import videoRoutes from './routes/videoRoutes.js';


const app = express();
const port = 3000;



app.use('/api', videoRoutes);

app.use('/images', express.static('public/images'));
app.use('/videos', express.static('public/videos'));

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
