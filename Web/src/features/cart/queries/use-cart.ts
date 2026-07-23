"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { usePathname, useRouter } from "next/navigation";
import { cartApi } from "@/features/cart/api/cart-api";
import { queryKeys } from "@/lib/query/keys";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { ApiError } from "@/lib/api/envelope";
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
  const router = useRouter();
  const pathname = usePathname();
  const { data: user, isLoading: authLoading } = useCurrentUser();

  return useMutation({
    mutationFn: async (input: AddToCartInput) => {
      if (!authLoading && !user) {
        router.push(`/login?redirect=${encodeURIComponent(pathname || "/")}`);
        throw new ApiError("Sepete eklemek için giriş yapmalısınız", 401);
      }
      return cartApi.addItem(input);
    },
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

export function useRemoveCartItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (productId: string) => cartApi.removeItem(productId),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.cart.all, data);
    },
  });
}

export function useClearCart() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => cartApi.clear(),
    onSuccess: () => {
      queryClient.setQueryData(queryKeys.cart.all, {
        items: [],
        totalAmount: 0,
        subtotal: 0,
        currency: "TRY",
      });
    },
  });
}

export function useCartItemCount() {
  const { data } = useCart();
  return data?.items.reduce((sum, item) => sum + item.quantity, 0) ?? 0;
}
