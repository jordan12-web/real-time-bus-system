import { generateTicket, validateTicket, revokeTicket } from '../services/ticketService.js';

export const postGenerateTicket = async (req, res, next) => {
  try {
    const { bookingId } = req.params;
    const result = await generateTicket({
      bookingId,
      userId: req.user.id,
      role: req.user.role
    });

    return res.status(201).json(result);
  } catch (error) {
    next(error);
  }
};

export const postValidateTicket = async (req, res, next) => {
  try {
    const { qr_code_data } = req.body;
    const result = await validateTicket({ qr_code_data });
    if (!result.valid) {
      return res.status(400).json(result);
    }
    return res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

export const postRevokeTicket = async (req, res, next) => {
  try {
    const { id } = req.params;
    const ticket = await revokeTicket({ ticketId: id });
    return res.status(200).json({ ticket });
  } catch (error) {
    next(error);
  }
};
