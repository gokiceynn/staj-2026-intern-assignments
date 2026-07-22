import { apiClient, authClient } from "@/lib/api/client";
import type {
  LoginData,
  OtpSession,
  User,
} from "@/types/api";
import type {
  ForgotPasswordInput,
  LoginInput,
  RegisterInput,
  ResetPasswordInput,
  VerifyEmailInput,
} from "@/features/auth/schemas/auth";

export const authApi = {
  login: (input: LoginInput) =>
    authClient<{ user: User }>("login", { method: "POST", body: input }),

  logout: () => authClient<{ ok: boolean }>("logout", { method: "POST" }),

  register: (input: RegisterInput) =>
    authClient<OtpSession>("register", { method: "POST", body: input }),

  verifyEmail: (input: VerifyEmailInput) =>
    authClient<{ user: User }>("verify-email", { method: "POST", body: input }),

  forgotPassword: (input: ForgotPasswordInput) =>
    authClient<OtpSession>("forgot-password", {
      method: "POST",
      body: input,
    }),

  resetPassword: (input: ResetPasswordInput) =>
    authClient<{ ok: boolean }>("reset-password", {
      method: "POST",
      body: input,
    }),

  getMe: () => apiClient<User>("account/me"),
};

export type { LoginData };
