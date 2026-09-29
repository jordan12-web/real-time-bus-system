import { GoogleGenerativeAI } from "@google/generative-ai";
import Booking from "../models/Booking.js";
import Trip from "../models/Trip.js";
import "dotenv/config";
import TripLocation from "../models/TripLocation.js";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

export const buildPassengerContext = async (userId) => {
  const booking = await Booking.findOne({
    user_id: userId,
    status: { $in: ["confirmed", "pending"] },
  })
    .sort({ created_at: -1 })
    .populate("trip_id");

  if (!booking || !booking.trip_id) {
    return {
      hasActiveBooking: false,
      message: "No active or upcoming bookings found for this passenger.",
    };
  }

  const trip = booking.trip_id;

  const latestLocation = await TripLocation.findOne({ trip_id: trip._id }).sort(
    { recorded_at: -1 },
  );

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

  // Try gemini-3.5-flash first, fallback to gemini-3.5-flash-lite if busy
  try {
    const primaryModel = genAI.getGenerativeModel({
      model: "gemini-3.5-flash",
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.2,
      },
    });
    const result = await primaryModel.generateContent(prompt);
    responseText = result.response.text();
  } catch (primaryErr) {
    console.warn("Primary model gemini-3.5-flash failed, trying gemini-3.5-flash-lite...", primaryErr.message);
    const fallbackModel = genAI.getGenerativeModel({
      model: "gemini-3.5-flash-lite",
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.2,
      },
    });
    const result = await fallbackModel.generateContent(prompt);
    responseText = result.response.text();
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
