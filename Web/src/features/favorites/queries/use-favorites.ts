"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { favoritesApi } from "@/features/favorites/api/favorites-api";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { queryKeys } from "@/lib/query/keys";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";

type FavoritesQuery = {
  page?: number;
  size?: number;
};

export function useFavoritesList(params: FavoritesQuery = { page: 1, size: 12 }) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.favorites.list(params),
    queryFn: () => favoritesApi.list(params),
    enabled: Boolean(user),
    staleTime: 30_000,
  });
}

export function useFavoriteIds() {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.favorites.ids,
    queryFn: async () => {
      const result = await favoritesApi.list({ page: 1, size: 200 });
      return new Set(result.items.map((item) => item.id));
    },
    enabled: Boolean(user),
    staleTime: 30_000,
  });
}

export function useToggleFavorite() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();

  return useMutation({
    mutationFn: async ({
      productId,
      isFavorite,
    }: {
      productId: string;
      isFavorite: boolean;
    }) => {
      if (isFavorite) {
        await favoritesApi.remove(productId);
      } else {
        await favoritesApi.add(productId);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.favorites.all });
    },
    onError: (err) => {
      showToast(
        err instanceof ApiError ? err.message : "Favori işlemi başarısız",
        "error",
      );
    },
  });
}

export function useFavorites() {
  const { data: user } = useCurrentUser();
  const { data: favoriteIds } = useFavoriteIds();
  const toggleFavorite = useToggleFavorite();

  const has = (productId: string) => favoriteIds?.has(productId) ?? false;

  const toggle = (productId: string) => {
    if (!user) return;
    toggleFavorite.mutate({ productId, isFavorite: has(productId) });
  };

  return {
    has,
    toggle,
    isAvailable: Boolean(user),
    isPending: toggleFavorite.isPending,
  };
}
