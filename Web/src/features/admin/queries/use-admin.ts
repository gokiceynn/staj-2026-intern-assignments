"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  adminApi,
  type ShippingCarrierWriteInput,
} from "@/features/admin/api/admin-api";
import { queryKeys } from "@/lib/query/keys";
import { useCurrentUser } from "@/features/auth/queries/use-auth";

export function useAdminDashboard(params?: { from?: string; to?: string }) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.dashboard(params ?? {}),
    queryFn: () => adminApi.getDashboard(params),
    enabled: user?.role === "Admin",
    staleTime: 30_000,
  });
}

export function useAdminUsers(params?: {
  page?: number;
  size?: number;
  q?: string;
  role?: string;
  isActive?: boolean;
}) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.users(params ?? {}),
    queryFn: () => adminApi.listUsers(params),
    enabled: user?.role === "Admin",
    staleTime: 10_000,
  });
}

export function useAdminUser(id: string) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.user(id),
    queryFn: () => adminApi.getUser(id),
    enabled: user?.role === "Admin" && Boolean(id),
  });
}

export function useAdminSellers(params?: {
  page?: number;
  size?: number;
  q?: string;
  isActive?: boolean;
}) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.sellers(params ?? {}),
    queryFn: () => adminApi.listSellers(params),
    enabled: user?.role === "Admin",
    staleTime: 10_000,
  });
}

export function useAdminSeller(id: string) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.seller(id),
    queryFn: () => adminApi.getSeller(id),
    enabled: user?.role === "Admin" && Boolean(id),
  });
}

export function useAdminOrders(params?: {
  page?: number;
  size?: number;
  status?: string;
  from?: string;
  to?: string;
}) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.orders(params ?? {}),
    queryFn: () => adminApi.listOrders(params),
    enabled: user?.role === "Admin",
    staleTime: 10_000,
  });
}

export function useAdminOrder(id: string) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.order(id),
    queryFn: () => adminApi.getOrder(id),
    enabled: user?.role === "Admin" && Boolean(id),
  });
}

export function useAdminCarriers() {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.carriers,
    queryFn: () => adminApi.listCarriers(),
    enabled: user?.role === "Admin",
    staleTime: 60_000,
  });
}

export function useAdminCarrier(id: string) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.admin.carrier(id),
    queryFn: () => adminApi.getCarrier(id),
    enabled: user?.role === "Admin" && Boolean(id),
  });
}

export function useCreateAdminCarrier() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: ShippingCarrierWriteInput) => adminApi.createCarrier(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.admin.carriers });
    },
  });
}

export function useUpdateAdminCarrier() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      input,
    }: {
      id: string;
      input: ShippingCarrierWriteInput;
    }) => adminApi.updateCarrier(id, input),
    onSuccess: (data, { id }) => {
      queryClient.setQueryData(queryKeys.admin.carrier(id), data);
      queryClient.invalidateQueries({ queryKey: queryKeys.admin.carriers });
    },
  });
}

export function useDeleteAdminCarrier() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteCarrier(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.admin.carriers });
    },
  });
}
