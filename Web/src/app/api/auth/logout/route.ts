import { NextResponse } from "next/server";
import {
  ACCESS_TOKEN_COOKIE,
  REFRESH_TOKEN_COOKIE,
} from "@/lib/auth/cookies";
import { getServerApiBaseUrl } from "@/lib/api/config";
import { getAccessToken } from "@/lib/auth/session";

export async function POST() {
  const access = await getAccessToken();

  if (access) {
    try {
      await fetch(`${getServerApiBaseUrl()}/auth/logout`, {
        method: "POST",
        headers: { Authorization: `Bearer ${access}` },
        cache: "no-store",
      });
    } catch {
      // Backend unreachable — still clear local session.
    }
  }

  const response = NextResponse.json({ ok: true });
  response.cookies.delete(ACCESS_TOKEN_COOKIE);
  response.cookies.delete(REFRESH_TOKEN_COOKIE);
  return response;
}
