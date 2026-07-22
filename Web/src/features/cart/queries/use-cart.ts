"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { usePathname, useRouter } from "next/navigation";
import { cartApi } from "@/features/cart/api/cart-api";
import { queryKeys } from "@/lib/query/keys";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";
import type { AddToCartInput, UpdateCartItemInput } from "@/features/cart/schemas/cart";
import type { CartProductSnapshot } from "@/features/cart/lib/cart-optimistic";
import {
  optimisticAddItem,
  optimisticClearCart,
  optimisticRemoveItem,
  optimisticUpdateItem,
} from "@/features/cart/lib/cart-optimistic";
import type { Cart } from "@/types/api";

export type AddToCartMutationInput = AddToCartInput & {
  product?: CartProductSnapshot;
};

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
  const { showToast } = useToast();

  return useMutation({
    mutationFn: async (input: AddToCartMutationInput) => {
      if (!authLoading && !user) {
        router.push(`/login?redirect=${encodeURIComponent(pathname || "/")}`);
        throw new ApiError("Sepete eklemek için giriş yapmalısınız", 401);
      }
      const { product: _product, ...body } = input;
      return cartApi.addItem(body);
    },
    onMutate: async (input) => {
      if (!user) return;

      await queryClient.cancelQueries({ queryKey: queryKeys.cart.all });

      const previousCart = queryClient.getQueryData<Cart>(queryKeys.cart.all);

      queryClient.setQueryData<Cart>(queryKeys.cart.all, (old) =>
        optimisticAddItem(old, input.productId, input.quantity, input.product),
      );

      return { previousCart };
    },
    onError: (err, _input, context) => {
      if (context?.previousCart) {
        queryClient.setQueryData(queryKeys.cart.all, context.previousCart);
      }
      if (err instanceof ApiError && err.code === 401) return;
      showToast(
        err instanceof ApiError ? err.message : "Sepete eklenemedi",
        "error",
      );
    },
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.cart.all, data);
    },
  });
}

export function useUpdateCartItem() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();

  return useMutation({
    mutationFn: ({
      productId,
      input,
    }: {
      productId: string;
      input: UpdateCartItemInput;
    }) => cartApi.updateItem(productId, input),
    onMutate: async ({ productId, input }) => {
      await queryClient.cancelQueries({ queryKey: queryKeys.cart.all });

      const previousCart = queryClient.getQueryData<Cart>(queryKeys.cart.all);

      queryClient.setQueryData<Cart>(queryKeys.cart.all, (old) =>
        optimisticUpdateItem(old, productId, input.quantity),
      );

      return { previousCart };
    },
    onError: (err, _vars, context) => {
      if (context?.previousCart) {
        queryClient.setQueryData(queryKeys.cart.all, context.previousCart);
      }
      showToast(
        err instanceof ApiError ? err.message : "Sepet güncellenemedi",
        "error",
      );
    },
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.cart.all, data);
    },
  });
}

export function useRemoveCartItem() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();

  return useMutation({
    mutationFn: (productId: string) => cartApi.removeItem(productId),
    onMutate: async (productId) => {
      await queryClient.cancelQueries({ queryKey: queryKeys.cart.all });

      const previousCart = queryClient.getQueryData<Cart>(queryKeys.cart.all);

      queryClient.setQueryData<Cart>(queryKeys.cart.all, (old) =>
        optimisticRemoveItem(old, productId),
      );

      return { previousCart };
    },
    onError: (err, _productId, context) => {
      if (context?.previousCart) {
        queryClient.setQueryData(queryKeys.cart.all, context.previousCart);
      }
      showToast(
        err instanceof ApiError ? err.message : "Ürün kaldırılamadı",
        "error",
      );
    },
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.cart.all, data);
    },
  });
}

export function useClearCart() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();

  return useMutation({
    mutationFn: () => cartApi.clear(),
    onMutate: async () => {
      await queryClient.cancelQueries({ queryKey: queryKeys.cart.all });

      const previousCart = queryClient.getQueryData<Cart>(queryKeys.cart.all);

      queryClient.setQueryData(queryKeys.cart.all, optimisticClearCart());

      return { previousCart };
    },
    onError: (err, _vars, context) => {
      if (context?.previousCart) {
        queryClient.setQueryData(queryKeys.cart.all, context.previousCart);
      }
      showToast(
        err instanceof ApiError ? err.message : "Sepet temizlenemedi",
        "error",
      );
    },
    onSuccess: () => {
      queryClient.setQueryData(queryKeys.cart.all, optimisticClearCart());
    },
  });
}

export function useCartItemCount() {
  const { data } = useCart();
  return data?.items.reduce((sum, item) => sum + item.quantity, 0) ?? 0;
}
