import { GoogleGenerativeAI } from "@google/generative-ai";
import "dotenv/config";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function quickTest() {
  const model = genAI.getGenerativeModel({ model: "gemini-3.5-flash" });
  const result = await model.generateContent("Hello Gemini!");
  console.log(result.response.text());
}

quickTest();
