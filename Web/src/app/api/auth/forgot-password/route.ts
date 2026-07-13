import { NextRequest, NextResponse } from "next/server";
import { getServerApiBaseUrl } from "@/lib/api/config";
import { parseApiResponse } from "@/lib/api/envelope";
import type { OtpSession } from "@/types/api";

export async function POST(request: NextRequest) {
  const body = await request.json();

  const upstream = await fetch(
    `${getServerApiBaseUrl()}/auth/forgot-password`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      cache: "no-store",
    },
  );

  const data = await parseApiResponse<OtpSession>(upstream);
  return NextResponse.json(data);
}
