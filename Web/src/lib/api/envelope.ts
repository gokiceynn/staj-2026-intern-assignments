import type { ApiResponse } from "@/types/api";

export class ApiError extends Error {
  constructor(
    message: string,
    public code: number,
    public errors: Record<string, string[]> | null = null,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export async function parseApiResponse<T>(
  response: Response,
): Promise<T> {
  const contentType = response.headers.get("content-type") ?? "";

  if (!contentType.includes("application/json")) {
    throw new ApiError(
      response.ok ? "Unexpected response format" : response.statusText,
      response.status,
    );
  }

  const body = (await response.json()) as ApiResponse<T>;

  if (!response.ok || !body.isSuccess) {
    throw new ApiError(
      body.message || "Request failed",
      body.code || response.status,
      body.errors,
    );
  }

  return body.data as T;
}

export function getFieldErrors(
  error: unknown,
): Record<string, string[]> | null {
  if (error instanceof ApiError) {
    return error.errors;
  }
  return null;
}
