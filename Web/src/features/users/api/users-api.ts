import { apiClient } from "@/lib/api/client";
import type { User } from "@/types/api";
import type {
  ChangePasswordInput,
  UpdateProfileInput,
} from "@/features/auth/schemas/auth";

export const usersApi = {
  getMe: () => apiClient<User>("users/me"),

  updateMe: (input: UpdateProfileInput) =>
    apiClient<User>("users/me", { method: "PUT", body: input }),

  changePassword: (input: ChangePasswordInput) =>
    apiClient<null>("users/me/password", { method: "PUT", body: input }),

  deleteMe: (password: string) =>
    apiClient<null>("users/me", { method: "DELETE", body: { password } }),
};
