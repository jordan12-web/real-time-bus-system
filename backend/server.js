import dotenv from 'dotenv';
dotenv.config();

import app from './app.js';
import connectDB from './config/db.js';

const PORT = process.env.PORT || 3000;

process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION! Shutting down...', err.message);
  process.exit(1);
});

const logGeminiAssistantConfig = () => {
  const raw = process.env.GEMINI_API_KEY;
  const key = typeof raw === "string" ? raw.trim().replace(/^["']|["']$/g, "") : "";
  if (!key) {
    console.warn(
      "Smart Passenger Assistant: GEMINI_API_KEY is not set — AI replies will use booking data only until configured.",
    );
    return;
  }
  console.log("Smart Passenger Assistant: GEMINI_API_KEY is configured.");
};

const startServer = async () => {
  logGeminiAssistantConfig();
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
