"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { cartApi } from "@/features/cart/api/cart-api";
import { queryKeys } from "@/lib/query/keys";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import type { AddToCartInput, UpdateCartItemInput } from "@/features/cart/schemas/cart";

export function useCart() {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.cart.all,
    queryFn: () => cartApi.get(),
    enabled: Boolean(user),
    staleTime: 10_000,
    retry: false,
  });
}

export function useAddToCart() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: AddToCartInput) => cartApi.addItem(input),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.cart.all, data);
    },
  });
}

export function useUpdateCartItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      productId,
      input,
    }: {
      productId: string;
      input: UpdateCartItemInput;
    }) => cartApi.updateItem(productId, input),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.cart.all, data);
    },
  });
}

export function useCartItemCount() {
  const { data } = useCart();
  return data?.items.reduce((sum, item) => sum + item.quantity, 0) ?? 0;
}
