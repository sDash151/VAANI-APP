import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './models/user.model.js'; // Adjust the path based on your project

dotenv.config();

async function main() {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    const dummyUser = new User({
      email: 'testuser@example.com',
      password: 'dummyPassword123', // will be hidden by select: false
      preferences: { language: 'hindi' },
    });

    await dummyUser.save();
    console.log('✅ Dummy user inserted successfully');

    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  } catch (err) {
    console.error('❌ Error inserting dummy user:', err);
  }
}

main();
