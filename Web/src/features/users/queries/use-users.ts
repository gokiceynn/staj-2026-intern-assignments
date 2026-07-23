"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { usersApi } from "@/features/users/api/users-api";
import { queryKeys } from "@/lib/query/keys";
import type {
  ChangePasswordInput,
  UpdateProfileInput,
} from "@/features/auth/schemas/auth";

export function useProfile() {
  return useQuery({
    queryKey: queryKeys.auth.me,
    queryFn: () => usersApi.getMe(),
    staleTime: 60_000,
  });
}

export function useUpdateProfile() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateProfileInput) => usersApi.updateMe(input),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.auth.me, data);
    },
  });
}

export function useChangePassword() {
  return useMutation({
    mutationFn: (input: ChangePasswordInput) => usersApi.changePassword(input),
  });
}

export function useDeleteAccount() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (password: string) => usersApi.deleteMe(password),
    onSuccess: () => {
      queryClient.clear();
    },
  });
}

export function useStartEmailChange() {
  return useMutation({
    mutationFn: (input: { newEmail: string; password: string }) =>
      usersApi.startEmailChange(input),
  });
}

export function useVerifyEmailChange() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { sessionId: string; code: string }) =>
      usersApi.verifyEmailChange(input),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.auth.me, data);
    },
  });
}

export function useResendEmailChange() {
  return useMutation({
    mutationFn: (password: string) => usersApi.resendEmailChange(password),
  });
}
