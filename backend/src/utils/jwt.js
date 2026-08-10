import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'default_access_secret';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'default_refresh_secret';

export const signAccessToken = (payload) => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '15m' });
};

export const signRefreshToken = (payload) => {
  return jwt.sign(payload, JWT_REFRESH_SECRET, { expiresIn: '7d' });
};

export const verifyAccessToken = (token) => {
  return jwt.verify(token, JWT_SECRET);
};

export const verifyRefreshToken = (token) => {
  return jwt.verify(token, JWT_REFRESH_SECRET);
};
