import {
  registerUser,
  loginUser,
  getUserById,
  refreshAuthToken,
} from "../services/authService.js";

export const signup = async (req, res, next) => {
  try {
    const { full_name, email, password, phone_number } = req.body;
    if (!full_name || !email || !password) {
      return res
        .status(400)
    }

    const result = await registerUser({
      full_name,
      email,
      password,
      phone_number,
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
      return res.status(400).json({ error: "email and password are required" });
    }

    const result = await loginUser({ email, password });
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
    const tokens = await refreshAuthToken(refreshToken);
    return res.status(200).json(tokens);
  } catch (error) {
    next(error);
  }
};
