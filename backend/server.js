import dotenv from 'dotenv';
dotenv.config();

import app from './app.js';
import connectDB from './config/db.js';

const PORT = process.env.PORT || 3000;

process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION! Shutting down...', err.message);
  process.exit(1);
});

const startServer = async () => {
  await connectDB();
  const server = app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });

  process.on('unhandledRejection', (err) => {
    console.error('UNHANDLED REJECTION! Shutting down...', err.message);
    server.close(() => {
      process.exit(1);
    });
  });
};

startServer();
