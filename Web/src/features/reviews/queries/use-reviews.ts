"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  reviewsApi,
  type ReviewWriteInput,
} from "@/features/reviews/api/reviews-api";
import { queryKeys } from "@/lib/query/keys";

export function useProductReviews(
  productId: string,
  params?: { page?: number; size?: number; sortBy?: string },
) {
  return useQuery({
    queryKey: queryKeys.reviews.list(productId, params ?? {}),
    queryFn: () => reviewsApi.list(productId, params),
    enabled: Boolean(productId),
  });
}

export function useCreateReview(productId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: ReviewWriteInput) =>
      reviewsApi.create(productId, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.reviews.all(productId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.products.detail(productId) });
    },
  });
}

export function useUpdateReview(productId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      reviewId,
      input,
    }: {
      reviewId: string;
      input: ReviewWriteInput;
    }) => reviewsApi.update(productId, reviewId, input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.reviews.all(productId) });
    },
  });
}

export function useDeleteReview(productId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (reviewId: string) => reviewsApi.delete(productId, reviewId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.reviews.all(productId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.products.detail(productId) });
    },
  });
}
