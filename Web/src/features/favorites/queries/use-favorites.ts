"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { favoritesApi } from "@/features/favorites/api/favorites-api";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { queryKeys } from "@/lib/query/keys";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";
import type { Paginated, ProductListItem } from "@/types/api";

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
    onMutate: async ({ productId, isFavorite }) => {
      await queryClient.cancelQueries({ queryKey: queryKeys.favorites.all });

      const previousIds = queryClient.getQueryData<Set<string>>(
        queryKeys.favorites.ids,
      );

      queryClient.setQueryData<Set<string>>(queryKeys.favorites.ids, (old) => {
        const next = new Set(old ?? []);
        if (isFavorite) {
          next.delete(productId);
        } else {
          next.add(productId);
        }
        return next;
      });

      const previousLists = queryClient.getQueriesData<Paginated<ProductListItem>>({
        queryKey: ["favorites", "list"],
      });

      if (isFavorite) {
        queryClient.setQueriesData<Paginated<ProductListItem>>(
          { queryKey: ["favorites", "list"] },
          (old) => {
            if (!old) return old;
            return {
              ...old,
              items: old.items.filter((item) => item.id !== productId),
              totalCount: Math.max(0, old.totalCount - 1),
            };
          },
        );
      }

      return { previousIds, previousLists };
    },
    onError: (err, _vars, context) => {
      if (context?.previousIds) {
        queryClient.setQueryData(queryKeys.favorites.ids, context.previousIds);
      }
      if (context?.previousLists) {
        for (const [key, data] of context.previousLists) {
          queryClient.setQueryData(key, data);
        }
      }
      showToast(
        err instanceof ApiError ? err.message : "Favori işlemi başarısız",
        "error",
      );
    },
    onSuccess: (_data, { isFavorite }) => {
      showToast(
        isFavorite ? "Favorilerden çıkarıldı" : "Favorilere eklendi",
        "success",
      );
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.favorites.all });
    },
  });
}

export function useFavorites() {
  const { data: user } = useCurrentUser();
  const { data: favoriteIds } = useFavoriteIds();
  const toggleFavorite = useToggleFavorite();
  const { showToast } = useToast();

  const has = (productId: string) => favoriteIds?.has(productId) ?? false;

  const toggle = (productId: string) => {
    if (!user) {
      showToast("Favoriler için giriş yapmalısınız", "error");
      return;
    }
    toggleFavorite.mutate({ productId, isFavorite: has(productId) });
  };

  const remove = (productId: string) => {
    if (!user) {
      showToast("Favoriler için giriş yapmalısınız", "error");
      return;
    }
    if (!has(productId)) return;
    toggleFavorite.mutate({ productId, isFavorite: true });
  };

  return {
    has,
    toggle,
    remove,
    isAvailable: Boolean(user),
    isPending: toggleFavorite.isPending,
  };
}
