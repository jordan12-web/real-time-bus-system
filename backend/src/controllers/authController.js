import { registerUser, loginUser, getUserById, refreshAuthToken } from '../services/authService.js';

export const signup = async (req, res, next) => {
  try {
    const { full_name, email, password, phone_number } = req.body;
    if (!full_name || typeof full_name !== 'string' || !full_name.trim()) {
      return res.status(400).json({ error: 'full_name is required and must be a non-empty string' });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || typeof email !== 'string' || !emailRegex.test(email.trim())) {
      return res.status(400).json({ error: 'A valid email address is required' });
    }

    if (!password || typeof password !== 'string' || password.length < 6) {
      return res.status(400).json({ error: 'password is required and must be at least 6 characters long' });
    }

    const result = await registerUser({
      full_name: full_name.trim(),
      email: email.trim(),
      password,
      phone_number: phone_number ? phone_number.trim() : null
    });
    return res.status(201).json(result);
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const result = await loginUser({ email: email.trim(), password });
    return res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req, res, next) => {
  try {
    const user = await getUserById(req.user.id);
    return res.status(200).json({ user });
  } catch (error) {
    next(error);
  }
};

export const refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken || typeof refreshToken !== 'string') {
      return res.status(400).json({ error: 'refreshToken string is required' });
    }
    const tokens = await refreshAuthToken(refreshToken);
    return res.status(200).json(tokens);
  } catch (error) {
    next(error);
  }
};
