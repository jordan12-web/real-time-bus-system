import User from '../models/User.js';

export const listUsers = async () => {
  const users = await User.find().sort({ created_at: -1 });
  return users.map((u) => u.toJSON());
};

const VALID_ROLES = ['passenger', 'driver', 'admin'];

export const updateUserRole = async (id, newRole, requestingUserId) => {
  if (!VALID_ROLES.includes(newRole)) {
    const error = new Error(`role must be one of: ${VALID_ROLES.join(', ')}`);
    error.statusCode = 400;
    throw error;
  }

  if (id === requestingUserId && newRole !== 'admin') {
    const error = new Error('You cannot change your own role.');
    error.statusCode = 400;
    throw error;
  }

  const user = await User.findById(id);
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  user.role = newRole;
  await user.save();
  return user.toJSON();
};