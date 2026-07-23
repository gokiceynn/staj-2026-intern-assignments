"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { addressesApi } from "@/features/addresses/api/addresses-api";
import { queryKeys } from "@/lib/query/keys";
import type { AddressInput } from "@/features/addresses/schemas/address";

export function useAddresses() {
  return useQuery({
    queryKey: queryKeys.addresses.all,
    queryFn: () => addressesApi.list(),
    staleTime: 60_000,
  });
}

export function useAddress(id: string) {
  return useQuery({
    queryKey: queryKeys.addresses.detail(id),
    queryFn: () => addressesApi.getById(id),
    enabled: Boolean(id),
  });
}

export function useCreateAddress() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: AddressInput) => addressesApi.create(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.addresses.all });
    },
  });
}

export function useUpdateAddress() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, input }: { id: string; input: AddressInput }) =>
      addressesApi.update(id, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.addresses.all });
    },
  });
}

export function useDeleteAddress() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => addressesApi.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.addresses.all });
    },
  });
}
