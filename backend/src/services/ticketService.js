import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import QRCode from 'qrcode';
import Ticket from '../models/Ticket.js';
import Booking from '../models/Booking.js';

const JWT_SECRET = process.env.JWT_SECRET || 'default_access_secret';

const ensureUploadsDirExists = () => {
  const dir = path.join(process.cwd(), 'uploads', 'tickets');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
};

export const generateTicket = async ({ bookingId, userId, role }) => {
  const booking = await Booking.findById(bookingId);
  if (!booking) {
    const error = new Error('Booking not found');
    error.statusCode = 404;
    throw error;
  }

  if (role !== 'admin' && booking.user_id.toString() !== userId) {
    const error = new Error('Forbidden: Access denied to this booking');
    error.statusCode = 403;
    throw error;
  }

  if (booking.status !== 'confirmed') {
    const error = new Error('Ticket can only be generated for confirmed bookings');
    error.statusCode = 400;
    throw error;
  }

  const existingTicket = await Ticket.findOne({ booking_id: bookingId });
  if (existingTicket) {
    return {
      ticket: existingTicket.toJSON(),
      qr_code_image_url: existingTicket.qr_code_image_url,
      qr_code_data: existingTicket.qr_code_data
    };
  }

  const ticket = new Ticket({
    booking_id: booking._id,
    qr_code_data: 'pending',
    status: 'issued',
    issued_at: new Date()
  });

  const payloadData = {
    t: ticket._id.toString(),
    b: booking._id.toString(),
    u: booking.user_id.toString(),
    r: booking.trip_id.toString(),
    iat: Math.floor(Date.now() / 1000)
  };

  const payloadString = `${payloadData.t}:${payloadData.b}:${payloadData.u}:${payloadData.r}:${payloadData.iat}`;
  const sig = crypto.createHmac('sha256', JWT_SECRET).update(payloadString).digest('hex');

  const fullPayload = { ...payloadData, sig };
  const qr_code_data = Buffer.from(JSON.stringify(fullPayload)).toString('base64');

  const uploadsDir = ensureUploadsDirExists();
  const fileName = `${ticket._id}.png`;
  const filePath = path.join(uploadsDir, fileName);

  await QRCode.toFile(filePath, qr_code_data);
  const qr_code_image_url = `/uploads/tickets/${fileName}`;

  ticket.qr_code_data = qr_code_data;
  ticket.qr_code_image_url = qr_code_image_url;
  await ticket.save();

  return {
    ticket: ticket.toJSON(),
    qr_code_image_url,
    qr_code_data
  };
};

export const validateTicket = async ({ qr_code_data }) => {
  if (!qr_code_data) {
    return { valid: false, reason: 'Missing qr_code_data parameter' };
  }

  let decoded;
  try {
    const jsonStr = Buffer.from(qr_code_data, 'base64').toString('utf-8');
    decoded = JSON.parse(jsonStr);
  } catch (e) {
    return { valid: false, reason: 'Invalid or malformed QR code format' };
  }

  const { t, b, u, r, iat, sig } = decoded;
  if (!t || !b || !u || !r || !iat || !sig) {
    return { valid: false, reason: 'Incomplete QR code payload fields' };
  }

  const payloadString = `${t}:${b}:${u}:${r}:${iat}`;
  const expectedSig = crypto.createHmac('sha256', JWT_SECRET).update(payloadString).digest('hex');

  if (sig !== expectedSig) {
    return { valid: false, reason: 'Invalid signature / tampered QR payload' };
  }

  const ticket = await Ticket.findById(t);
  if (!ticket) {
    return { valid: false, reason: 'Ticket record not found' };
  }

  if (ticket.status === 'used') {
    return { valid: false, reason: 'Ticket has already been used', ticket: ticket.toJSON() };
  }

  if (ticket.status === 'revoked') {
    return { valid: false, reason: 'Ticket has been revoked', ticket: ticket.toJSON() };
  }

  ticket.status = 'used';
  ticket.used_at = new Date();
  await ticket.save();

  return { valid: true, ticket: ticket.toJSON() };
};

export const revokeTicket = async ({ ticketId }) => {
  const ticket = await Ticket.findById(ticketId);
  if (!ticket) {
    const error = new Error('Ticket not found');
    error.statusCode = 404;
    throw error;
  }

  if (ticket.status === 'revoked') {
    const error = new Error('Ticket is already revoked');
    error.statusCode = 400;
    throw error;
  }

  ticket.status = 'revoked';
  ticket.revoked_at = new Date();
  await ticket.save();

  return ticket.toJSON();
};
