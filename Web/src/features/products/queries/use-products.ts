"use client";

import { useQuery } from "@tanstack/react-query";
import { productsApi } from "@/features/products/api/products-api";
import { queryKeys } from "@/lib/query/keys";
import type { ProductQueryParams } from "@/types/api";

export function useProducts(params: ProductQueryParams = {}) {
  return useQuery({
    queryKey: queryKeys.products.list(params),
    queryFn: () => productsApi.list(params),
    staleTime: 30_000,
  });
}

export function useProduct(id: string) {
  return useQuery({
    queryKey: queryKeys.products.detail(id),
    queryFn: () => productsApi.getById(id),
    enabled: Boolean(id),
    staleTime: 60_000,
  });
}

export function useDerivedCategories() {
  return useQuery({
    queryKey: queryKeys.products.categories,
    queryFn: async () => {
      const result = await productsApi.list({ page: 1, size: 100 });
      const map = new Map<string, string>();
      for (const item of result.items) {
        map.set(item.category.id, item.category.name);
      }
      return Array.from(map.entries()).map(([id, name]) => ({ id, name }));
    },
    staleTime: 300_000,
  });
}
