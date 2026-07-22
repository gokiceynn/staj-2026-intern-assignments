import { apiClient } from "@/lib/api/client";
import type { Paginated, ProductListItem } from "@/types/api";

type FavoritesQuery = {
  page?: number;
  size?: number;
};

export const favoritesApi = {
  list: ({ page = 1, size = 12 }: FavoritesQuery = {}) =>
    apiClient<Paginated<ProductListItem>>(
      `favorites?page=${page}&size=${size}`,
    ),

  add: (productId: string) =>
    apiClient<{ productId: string; addedAt: string }>(
      `favorites/${productId}`,
      { method: "POST" },
    ),

  remove: (productId: string) =>
    apiClient<null>(`favorites/${productId}`, { method: "DELETE" }),
};
