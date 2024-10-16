import express from 'express';
import videoRoutes from './routes/videoRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';
import connectToDatabase from './services/db_connection.js';


const app = express();
const port = 3000;

async function startServer(){
  await connectToDatabase();

  app.use(express.json())
  app.use('/api/videos', videoRoutes);
  app.use('/api/upload', uploadRoutes);

  app.use('/images', express.static('public/images'));
  app.use('/videos', express.static('public/videos'));

  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}

startServer();
