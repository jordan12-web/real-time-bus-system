import { getAdminStats } from '../services/adminService.js';

export const getStats = async (req, res, next) => {
  try {
    const stats = await getAdminStats();
    return res.status(200).json(stats);
  } catch (error) {
    next(error);
  }
};