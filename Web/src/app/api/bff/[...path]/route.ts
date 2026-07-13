import { NextRequest, NextResponse } from "next/server";
import {
  ACCESS_TOKEN_COOKIE,
  REFRESH_TOKEN_COOKIE,
  getAuthCookieOptions,
} from "@/lib/auth/cookies";
import { refreshAccessToken } from "@/lib/auth/refresh-manager";
import { getServerApiBaseUrl } from "@/lib/api/config";
import type { AuthTokens } from "@/types/api";

const PUBLIC_GET_PATTERNS = [/^products$/, /^products\/[^/]+$/, /^photos\/[^/]+$/];

function isPublicGet(segments: string[], method: string): boolean {
  if (method !== "GET") return false;
  const path = segments.join("/");
  return PUBLIC_GET_PATTERNS.some((pattern) => pattern.test(path));
}

function buildUpstreamUrl(segments: string[], search: string): string {
  return `${getServerApiBaseUrl()}/${segments.join("/")}${search}`;
}

async function forward(
  request: NextRequest,
  segments: string[],
  accessToken?: string,
): Promise<Response> {
  const headers = new Headers();
  const contentType = request.headers.get("content-type");
  if (contentType) headers.set("content-type", contentType);
  if (accessToken) headers.set("Authorization", `Bearer ${accessToken}`);

  const body =
    request.method === "GET" || request.method === "HEAD"
      ? undefined
      : await request.arrayBuffer();

  return fetch(buildUpstreamUrl(segments, request.nextUrl.search), {
    method: request.method,
    headers,
    body,
    cache: "no-store",
  });
}

function applyRefresh(response: NextResponse, tokens: AuthTokens): void {
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

async function toNextResponse(
  upstream: Response,
  tokens?: AuthTokens,
): Promise<NextResponse> {
  const data = await upstream.arrayBuffer();
  const response = new NextResponse(data, {
    status: upstream.status,
    headers: {
      "content-type":
        upstream.headers.get("content-type") ?? "application/json",
    },
  });
  if (tokens) applyRefresh(response, tokens);
  return response;
}

function unauthorizedResponse(): NextResponse {
  const res = NextResponse.json({ message: "Unauthorized" }, { status: 401 });
  res.cookies.delete(ACCESS_TOKEN_COOKIE);
  res.cookies.delete(REFRESH_TOKEN_COOKIE);
  return res;
}

async function handle(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> },
): Promise<NextResponse> {
  const { path: segments } = await context.params;

  if (isPublicGet(segments, request.method)) {
    const upstream = await forward(request, segments);
    return toNextResponse(upstream);
  }

  let access = request.cookies.get(ACCESS_TOKEN_COOKIE)?.value;
  const refresh = request.cookies.get(REFRESH_TOKEN_COOKIE)?.value;

  if (!access && !refresh) {
    return unauthorizedResponse();
  }

  if (!access && refresh) {
    const tokens = await refreshAccessToken(refresh);
    if (!tokens) return unauthorizedResponse();
    access = tokens.accessToken;
    const upstream = await forward(request, segments, access);
    return toNextResponse(upstream, tokens);
  }

  let upstream = await forward(request, segments, access);

  if (upstream.status === 401 && refresh) {
    const tokens = await refreshAccessToken(refresh, access);
    if (!tokens) return unauthorizedResponse();
    upstream = await forward(request, segments, tokens.accessToken);
    return toNextResponse(upstream, tokens);
  }

  return toNextResponse(upstream);
}

export async function GET(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> },
) {
  return handle(request, context);
}

export async function POST(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> },
) {
  return handle(request, context);
}

export async function PUT(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> },
) {
  return handle(request, context);
}

export async function DELETE(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> },
) {
  return handle(request, context);
}
