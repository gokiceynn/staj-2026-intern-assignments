"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { ordersApi } from "@/features/orders/api/orders-api";
import { queryKeys } from "@/lib/query/keys";
import type { CheckoutInput, CancelOrderInput } from "@/features/orders/schemas/order";

export function useOrders(params?: { page?: number; size?: number }) {
  return useQuery({
    queryKey: queryKeys.orders.list(params ?? {}),
    queryFn: () => ordersApi.list(params),
    staleTime: 30_000,
  });
}

export function useOrder(id: string) {
  return useQuery({
    queryKey: queryKeys.orders.detail(id),
    queryFn: () => ordersApi.getById(id),
    enabled: Boolean(id),
  });
}

export function useCheckout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CheckoutInput) => ordersApi.checkout(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.cart.all });
      queryClient.invalidateQueries({ queryKey: queryKeys.orders.all });
    },
  });
}

export function useCancelOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, input }: { id: string; input: CancelOrderInput }) =>
      ordersApi.cancel(id, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.orders.all });
    },
  });
}
