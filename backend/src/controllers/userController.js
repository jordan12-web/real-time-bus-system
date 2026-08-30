import { listUsers, updateUserRole } from '../services/userService.js';

export const getUsers = async (req, res, next) => {
  try {
    const users = await listUsers();
    return res.status(200).json(users);
  } catch (error) {
    next(error);
  }
};

export const patchUserRole = async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!role) {
      return res.status(400).json({ error: 'role is required' });
    }
    const user = await updateUserRole(req.params.id, role, req.user.id);
    return res.status(200).json(user);
  } catch (error) {
    next(error);
  }
};