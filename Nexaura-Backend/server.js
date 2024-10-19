import express from 'express';
import videoRoutes from './routes/videoRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';
import playlistRoutes from './routes/playlistRoutes.js';
import connectToDatabase from './services/db_connection.js';
import cookieParser from 'cookie-parser';

const app = express();
app.use(cookieParser());

const port = 3000;
// Safe cookie setting
app.get('/set-cookie', (req, res) => {
  const safeValue = encodeURIComponent("username"); // Sanitize value
  res.cookie('userName', safeValue, {
    httpOnly: true, // Prevent JS access
    secure: true,   // HTTPS only
    sameSite: 'strict', // CSRF protection
    maxAge: 2592000, // Expiry
  });
  res.send('Cookie is set safely');
});

async function startServer(){
  await connectToDatabase();

  app.use(express.json())
  app.use('/api/videos', videoRoutes);
  app.use('/api/upload', uploadRoutes);
  app.use('/api/playlist', playlistRoutes);

  app.use('/images', express.static('public/images'));
  app.use('/videos', express.static('public/videos'));

  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}

startServer();
