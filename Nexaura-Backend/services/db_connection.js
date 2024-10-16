import mongoose from 'mongoose';

// Your MongoDB connection string
const uri = "mongodb+srv://amritpalsingh220923:XNhUx.jhi9_GYpf@practicecluster.fzvaf.mongodb.net/nexaura?retryWrites=true&w=majority&appName=PracticeCluster";

let isConnected = false;

async function connectToDatabase() {
  if (!isConnected) {
    try {
      // Connect to MongoDB using Mongoose without deprecated options
      await mongoose.connect(uri);
      isConnected = true;
      console.log("Successfully connected to MongoDB");
    } catch (error) {
      console.error("Failed to connect to MongoDB:", error);
    }
  }
  return mongoose.connection; // Return the mongoose connection
}

// Export the connection function
export default connectToDatabase;
