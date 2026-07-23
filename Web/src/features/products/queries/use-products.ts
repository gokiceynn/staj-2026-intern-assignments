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
