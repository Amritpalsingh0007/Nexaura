import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema({
    _id: String,
    history: [String],
    likedvideos: [String],
    dislikedvideos: [String]
  });
  

const userModel = mongoose.model('user', UserSchema);

export default userModel;