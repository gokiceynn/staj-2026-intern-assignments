import { getServerApiBaseUrl } from "@/lib/api/config";
import { parseApiResponse } from "@/lib/api/envelope";
import type { AuthTokens } from "@/types/api";

let refreshPromise: Promise<AuthTokens | null> | null = null;

export async function refreshAccessToken(
  refreshToken: string,
  accessToken?: string,
): Promise<AuthTokens | null> {
  if (refreshPromise) {
    return refreshPromise;
  }

  refreshPromise = (async () => {
    try {
      const headers: HeadersInit = { "Content-Type": "application/json" };
      if (accessToken) {
        headers.Authorization = `Bearer ${accessToken}`;
      }

      const response = await fetch(
        `${getServerApiBaseUrl()}/auth/refresh-token`,
        {
          method: "POST",
          headers,
          body: JSON.stringify({ refreshToken }),
          cache: "no-store",
        },
      );

      return await parseApiResponse<AuthTokens>(response);
    } catch {
      return null;
    } finally {
      refreshPromise = null;
    }
  })();

  return refreshPromise;
}

export function resetRefreshManagerForTests() {
  refreshPromise = null;
}
