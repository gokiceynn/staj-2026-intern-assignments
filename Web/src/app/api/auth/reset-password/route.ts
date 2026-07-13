import { NextRequest, NextResponse } from "next/server";
import { getServerApiBaseUrl } from "@/lib/api/config";
import { parseApiResponse } from "@/lib/api/envelope";

export async function POST(request: NextRequest) {
  const body = await request.json();

  const upstream = await fetch(`${getServerApiBaseUrl()}/auth/reset-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });

  await parseApiResponse<null>(upstream);
  return NextResponse.json({ ok: true });
}
