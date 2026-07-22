import { NextRequest, NextResponse } from "next/server";
import { getServerApiBaseUrl } from "@/lib/api/config";
import { ApiError, parseApiResponse } from "@/lib/api/envelope";
import { normalizePhoneNumber } from "@/lib/utils/phone";
import type { OtpSession } from "@/types/api";

export async function POST(request: NextRequest) {
  const body = (await request.json()) as Record<string, unknown>;

  if (typeof body.phoneNumber === "string") {
    body.phoneNumber = normalizePhoneNumber(body.phoneNumber);
  }

  try {
    const upstream = await fetch(`${getServerApiBaseUrl()}/auth/customer/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      cache: "no-store",
    });

    const data = await parseApiResponse<OtpSession>(upstream);
    return NextResponse.json(data);
  } catch (error) {
    if (error instanceof ApiError) {
      return NextResponse.json(
        {
          data: null,
          isSuccess: false,
          message: error.message,
          code: error.code,
          errors: error.errors,
        },
        { status: error.code >= 400 && error.code < 600 ? error.code : 400 },
      );
    }

    throw error;
  }
}
