import { NextResponse } from "next/server";
import { isGeminiConfigured } from "@/lib/ai/config";

export async function GET() {
  return NextResponse.json({ configured: isGeminiConfigured() });
}
