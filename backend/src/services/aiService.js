import { GoogleGenerativeAI } from "@google/generative-ai";
import Booking from "../models/Booking.js";
import Trip from "../models/Trip.js";
import "dotenv/config";
import TripLocation from "../models/TripLocation.js";

class AssistantServiceError extends Error {
  constructor(message, statusCode = 503) {
    super(message);
    this.name = "AssistantServiceError";
    this.statusCode = statusCode;
  }
}

const assistantUnavailableMessage =
  "The Smart Passenger Assistant is temporarily unavailable. Please try again shortly.";

const primaryModelName = process.env.GEMINI_MODEL || "gemini-3.5-flash";
const fallbackModelName = process.env.GEMINI_FALLBACK_MODEL || "gemini-3.5-flash-lite";

const generationConfig = {
  responseMimeType: "application/json",
  temperature: 0.2,
};

const createGenerativeAI = () => {
  const apiKey = process.env.GEMINI_API_KEY?.trim();

  if (!apiKey || !apiKey.startsWith("AIza")) {
    throw new AssistantServiceError(assistantUnavailableMessage);
  }

  return new GoogleGenerativeAI(apiKey);
};

const getHttpStatus = (error) => error?.status || error?.statusCode;

const toAssistantError = (error) => {
  if (error instanceof AssistantServiceError) return error;

  const status = getHttpStatus(error);
  if (status === 429) {
    return new AssistantServiceError(
      "The Smart Passenger Assistant is busy. Please try again in a moment.",
    );
  }

  return new AssistantServiceError(assistantUnavailableMessage);
};

export const buildPassengerContext = async (userId) => {
  const booking = await Booking.findOne({
    user_id: userId,
    status: { $in: ["confirmed", "pending"] },
  })
    .sort({ created_at: -1 })
    .select("trip_id seat_number status total_amount currency")
    .populate({
      path: "trip_id",
      select:
        "origin destination departure_time arrival_time vehicle_id status",
    })
    .lean();

  if (!booking || !booking.trip_id) {
    return {
      hasActiveBooking: false,
      message: "No active or upcoming bookings found for this passenger.",
    };
  }

  const trip = booking.trip_id;

  const latestLocation = await TripLocation.findOne({ trip_id: trip._id })
    .sort({ recorded_at: -1 })
    .select("latitude longitude speed_kmh heading recorded_at")
    .lean();

  return {
    hasActiveBooking: true,
    booking: {
      bookingId: booking._id,
      seatNumber: booking.seat_number,
      bookingStatus: booking.status,
      totalAmount: booking.total_amount,
      currency: booking.currency,
    },
    trip: {
      tripId: trip._id,
      origin: trip.origin,
      destination: trip.destination,
      departureTime: trip.departure_time,
      arrivalTime: trip.arrival_time,
      vehicleId: trip.vehicle_id,
      tripStatus: trip.status,
    },
    liveTracking: latestLocation
      ? {
          latitude: latestLocation.latitude,
          longitude: latestLocation.longitude,
          speedKmh: latestLocation.speed_kmh,
          heading: latestLocation.heading,
          lastUpdated: latestLocation.recorded_at,
        }
      : {
          status: "No GPS coordinates reported yet for this trip.",
        },
  };
};

export const askPassengerAssistant = async (userId, userQuestion) => {
  const genAI = createGenerativeAI();
  const context = await buildPassengerContext(userId);

  const systemPrompt = `
You are the Smart Passenger Assistant (SPA) for Guzo Bus Service in Ethiopia.
Your job is to answer passenger questions accurately, concisely, and empathetically using ONLY the provided real-time trip and tracking data.

Rules:
1. Rely strictly on the context provided. Do not invent or assume bus positions, delays, or schedules.
2. If liveTracking has no data yet, inform the passenger that the bus has not started reporting its live GPS coordinates.
3. Be professional, friendly, and concise (under 3 sentences when possible).
4. You must output valid JSON matching this schema:
{
  "answer": "Your human-friendly message to the passenger",
  "confidence": 0.0 to 1.0,
  "actionType": "none" | "suggest_reschedule" | "suggest_reserve" | "notify_passengers"
}
`;

  const prompt = `
System Context:
${systemPrompt}

Current Real-Time Data Context:
${JSON.stringify(context, null, 2)}

Passenger Question:
"${userQuestion}"
`;

  let responseText;

  // Keep the established model request shape for reliable passenger responses.
  try {
    const primaryModel = genAI.getGenerativeModel({
      model: primaryModelName,
      generationConfig,
    });
    const result = await primaryModel.generateContent(prompt);
    responseText = result.response.text();
  } catch (primaryErr) {
    console.warn("Primary Gemini model failed; trying the fallback model.", {
      model: primaryModelName,
      status: getHttpStatus(primaryErr),
      message: primaryErr.message,
    });
    const fallbackModel = genAI.getGenerativeModel({
      model: fallbackModelName,
      generationConfig,
    });
    try {
      const result = await fallbackModel.generateContent(prompt);
      responseText = result.response.text();
    } catch (fallbackErr) {
      console.error("Gemini fallback request failed", {
        model: fallbackModelName,
        status: getHttpStatus(fallbackErr),
        message: fallbackErr.message,
      });
      throw toAssistantError(fallbackErr);
    }
  }

  try {
    return JSON.parse(responseText);
  } catch (err) {
    return {
      answer: responseText,
      confidence: 0.5,
      actionType: "none",
    };
  }
};
