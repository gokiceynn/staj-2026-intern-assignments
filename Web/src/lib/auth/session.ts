import { cookies } from "next/headers";
import {
  ACCESS_TOKEN_COOKIE,
  REFRESH_TOKEN_COOKIE,
  getAuthCookieOptions,
} from "@/lib/auth/cookies";
import { refreshAccessToken } from "@/lib/auth/refresh-manager";
import { getServerApiBaseUrl } from "@/lib/api/config";
import { parseApiResponse } from "@/lib/api/envelope";
import type { AuthTokens, User } from "@/types/api";

export async function getAccessToken(): Promise<string | undefined> {
  const store = await cookies();
  return store.get(ACCESS_TOKEN_COOKIE)?.value;
}

export async function getRefreshToken(): Promise<string | undefined> {
  const store = await cookies();
  return store.get(REFRESH_TOKEN_COOKIE)?.value;
}

export async function setAuthCookies(tokens: AuthTokens): Promise<void> {
  const store = await cookies();
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

  store.set(ACCESS_TOKEN_COOKIE, tokens.accessToken, {
    ...getAuthCookieOptions(accessMaxAge),
  });
  store.set(REFRESH_TOKEN_COOKIE, tokens.refreshToken, {
    ...getAuthCookieOptions(refreshMaxAge),
  });
}

export async function clearAuthCookies(): Promise<void> {
  const store = await cookies();
  store.delete(ACCESS_TOKEN_COOKIE);
  store.delete(REFRESH_TOKEN_COOKIE);
}

export async function fetchWithAuth<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const access = await getAccessToken();
  const refresh = await getRefreshToken();

  if (!access) {
    throw new Error("Unauthorized");
  }

  const doFetch = async (token: string) => {
    const headers = new Headers(init?.headers);
    headers.set("Authorization", `Bearer ${token}`);
    if (!headers.has("Content-Type") && init?.body) {
      headers.set("Content-Type", "application/json");
    }

    return fetch(`${getServerApiBaseUrl()}${path}`, {
      ...init,
      headers,
      cache: "no-store",
    });
  };

  let response = await doFetch(access);

  if (response.status === 401 && refresh) {
    const refreshed = await refreshAccessToken(refresh, access);
    if (!refreshed) {
      await clearAuthCookies();
      throw new Error("Unauthorized");
    }
    await setAuthCookies(refreshed);
    response = await doFetch(refreshed.accessToken);
  }

  return parseApiResponse<T>(response);
}

export async function getCurrentUser(): Promise<User | null> {
  const access = await getAccessToken();
  if (!access) return null;

  try {
    return await fetchWithAuth<User>("/account/me");
  } catch {
    return null;
  }
}

export async function requireUser(): Promise<User> {
  const user = await getCurrentUser();
  if (!user) {
    throw new Error("Unauthorized");
  }
  return user;
}
