export const ACCESS_TOKEN_COOKIE = "vbshop_access_token";
export const REFRESH_TOKEN_COOKIE = "vbshop_refresh_token";

export type CookieOptions = {
  httpOnly: boolean;
  secure: boolean;
  sameSite: "lax" | "strict" | "none";
  path: string;
  maxAge?: number;
};

export function getAuthCookieOptions(maxAge?: number): CookieOptions {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge,
  };
}
