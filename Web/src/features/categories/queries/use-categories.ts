"use client";

import { useQuery } from "@tanstack/react-query";
import { categoriesApi } from "@/features/categories/api/categories-api";
import { queryKeys } from "@/lib/query/keys";
import type { CategoryRef } from "@/types/api";

export function useCategories() {
  return useQuery({
    queryKey: queryKeys.categories.all,
    queryFn: () => categoriesApi.list(),
    staleTime: 300_000,
  });
}

export function useRootCategories() {
  return useQuery({
    queryKey: queryKeys.categories.all,
    queryFn: () => categoriesApi.list(),
    select: (categories): CategoryRef[] =>
      categories.map(({ id, name }) => ({ id, name })),
    staleTime: 300_000,
  });
}
