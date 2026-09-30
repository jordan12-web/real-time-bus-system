import { askPassengerAssistant } from '../services/aiService.js';

export const handleAiQuery = async (req, res, next) => {
  try {
    const { question } = req.body;

    if (!question || typeof question !== 'string' || !question.trim()) {
      return res.status(400).json({
        error: 'A valid question string is required in the request body.'
      });
    }

    const userId = req.user.id; 
    const aiResponse = await askPassengerAssistant(userId, question.trim());

    return res.status(200).json({
      success: true,
      data: aiResponse
    });
  } catch (error) {
    console.error('Error in AI Assistant handler:', error);
    if (error.statusCode) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    next(error);
  }
};
