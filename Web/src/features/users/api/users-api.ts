import { apiClient } from "@/lib/api/client";
import { normalizeAccountPayload } from "@/lib/auth/normalize-account";
import type { OtpSession, User } from "@/types/api";
import type {
  ChangePasswordInput,
  UpdateProfileInput,
} from "@/features/auth/schemas/auth";

export const usersApi = {
  getMe: async () =>
    normalizeAccountPayload(await apiClient<{ account: User }>("account/me")),

  updateMe: async (input: UpdateProfileInput) =>
    normalizeAccountPayload(
      await apiClient<{ account: User }>("account/me", {
        method: "PUT",
        body: input,
      }),
    ),

  changePassword: (input: ChangePasswordInput) =>
    apiClient<null>("account/me/password", { method: "PUT", body: input }),

  deleteMe: (password: string) =>
    apiClient<null>("customer/me", { method: "DELETE", body: { password } }),

  startEmailChange: (input: { newEmail: string; password: string }) =>
    apiClient<OtpSession>("account/me/email", { method: "PUT", body: input }),

  verifyEmailChange: (input: { sessionId: string; code: string }) =>
    apiClient<User>("account/me/email/verify", {
      method: "POST",
      body: input,
    }),

  resendEmailChange: (password: string) =>
    apiClient<OtpSession>("account/me/email/resend", {
      method: "POST",
      body: { password },
    }),
};
