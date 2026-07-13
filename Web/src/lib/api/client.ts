import { parseApiResponse } from "@/lib/api/envelope";

export type ApiClientOptions = Omit<RequestInit, "body"> & {
  body?: unknown;
  params?: Record<string, string | number | undefined>;
};

function buildBffUrl(path: string, params?: ApiClientOptions["params"]): string {
  const normalized = path.replace(/^\//, "");
  const url = new URL(`/api/bff/${normalized}`, window.location.origin);

  if (params) {
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined && value !== "") {
        url.searchParams.set(key, String(value));
      }
    }
  }

  return url.pathname + url.search;
}

export async function apiClient<T>(
  path: string,
  options: ApiClientOptions = {},
): Promise<T> {
  const { body, params, headers: customHeaders, ...init } = options;
  const headers = new Headers(customHeaders);

  let requestBody: BodyInit | undefined;
  if (body !== undefined) {
    if (!headers.has("Content-Type")) {
      headers.set("Content-Type", "application/json");
    }
    requestBody = JSON.stringify(body);
  }

  const response = await fetch(buildBffUrl(path, params), {
    ...init,
    headers,
    body: requestBody,
    credentials: "same-origin",
  });

  return parseApiResponse<T>(response);
}

export async function authClient<T>(
  path: string,
  options: ApiClientOptions = {},
): Promise<T> {
  const { body, headers: customHeaders, ...init } = options;
  const headers = new Headers(customHeaders);

  let requestBody: BodyInit | undefined;
  if (body !== undefined) {
    if (!headers.has("Content-Type")) {
      headers.set("Content-Type", "application/json");
    }
    requestBody = JSON.stringify(body);
  }

  const response = await fetch(`/api/auth/${path}`, {
    ...init,
    method: init.method ?? "POST",
    headers,
    body: requestBody,
    credentials: "same-origin",
  });

  const contentType = response.headers.get("content-type") ?? "";

  if (!response.ok) {
    if (contentType.includes("application/json")) {
      return parseApiResponse<T>(response);
    }
    throw new Error(response.statusText || "Request failed");
  }

  if (contentType.includes("application/json")) {
    return (await response.json()) as T;
  }

  throw new Error("Unexpected response format");
}
