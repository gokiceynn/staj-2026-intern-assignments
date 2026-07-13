import { getServerApiBaseUrl } from "@/lib/api/config";
import { parseApiResponse } from "@/lib/api/envelope";
import { fetchWithAuth } from "@/lib/auth/session";
import type { ProductQueryParams } from "@/types/api";
import { buildProductQueryParams } from "@/lib/utils/query-params";

export async function fetchPublic<T>(path: string): Promise<T> {
  const response = await fetch(`${getServerApiBaseUrl()}${path}`, {
    cache: "no-store",
  });
  return parseApiResponse<T>(response);
}

export async function fetchProtected<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  return fetchWithAuth<T>(path, init);
}

export function productListPath(params: ProductQueryParams): string {
  const query = new URLSearchParams(buildProductQueryParams(params));
  const qs = query.toString();
  return `/products${qs ? `?${qs}` : ""}`;
}
