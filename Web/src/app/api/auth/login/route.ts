import { NextRequest, NextResponse } from "next/server";
import {
  ACCESS_TOKEN_COOKIE,
  REFRESH_TOKEN_COOKIE,
  getAuthCookieOptions,
} from "@/lib/auth/cookies";
import { getServerApiBaseUrl } from "@/lib/api/config";
import { parseApiResponse } from "@/lib/api/envelope";
import type { AuthTokens, LoginData } from "@/types/api";

function applyTokens(response: NextResponse, tokens: AuthTokens) {
  const accessMaxAge = Math.max(
    60,
    Math.floor(
      (new Date(tokens.accessTokenExpiresAt).getTime() - Date.now()) / 1000,
    ),
  );
  const refreshMaxAge = Math.max(
    60,
    Math.floor(
      (new Date(tokens.refreshTokenExpiresAt).getTime() - Date.now()) / 1000,
    ),
  );

  response.cookies.set(ACCESS_TOKEN_COOKIE, tokens.accessToken, {
    ...getAuthCookieOptions(accessMaxAge),
  });
  response.cookies.set(REFRESH_TOKEN_COOKIE, tokens.refreshToken, {
    ...getAuthCookieOptions(refreshMaxAge),
  });
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const upstream = await fetch(`${getServerApiBaseUrl()}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    cache: "no-store",
  });

  const data = await parseApiResponse<LoginData>(upstream);
  const response = NextResponse.json({ user: data.user });
  applyTokens(response, data);
  return response;
}
