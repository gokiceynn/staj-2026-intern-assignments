import { apiClient } from "@/lib/api/client";
import { normalizePaginated } from "@/lib/api/pagination";
import { withPhotoUrls } from "@/lib/utils/photo-url";
import type { Paginated, ProductListItem } from "@/types/api";

type FavoritesQuery = {
  page?: number;
  size?: number;
};

export const favoritesApi = {
  list: async ({ page = 1, size = 12 }: FavoritesQuery = {}): Promise<Paginated<ProductListItem>> => {
    const result = normalizePaginated<ProductListItem>(
      await apiClient<unknown>(`favorites?page=${page}&size=${size}`),
    );
    return { ...result, items: withPhotoUrls(result.items) };
  },

  add: (productId: string) =>
    apiClient<{ productId: string; addedAt: string }>(
      `favorites/${productId}`,
      { method: "POST" },
    ),

  remove: (productId: string) =>
    apiClient<null>(`favorites/${productId}`, { method: "DELETE" }),
};
