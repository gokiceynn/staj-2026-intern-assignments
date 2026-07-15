import { apiClient } from "@/lib/api/client";
import type { User } from "@/types/api";
import type {
  ChangePasswordInput,
  UpdateProfileInput,
} from "@/features/auth/schemas/auth";

export const usersApi = {
  getMe: () => apiClient<User>("account/me"),

  updateMe: (input: UpdateProfileInput) =>
    apiClient<User>("account/me", { method: "PUT", body: input }),

  changePassword: (input: ChangePasswordInput) =>
    apiClient<null>("account/me/password", { method: "PUT", body: input }),

  deleteMe: (password: string) =>
    apiClient<null>("customer/me", { method: "DELETE", body: { password } }),
};
