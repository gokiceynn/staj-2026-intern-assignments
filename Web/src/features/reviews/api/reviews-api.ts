import { apiClient } from "@/lib/api/client";
import { normalizePaginated } from "@/lib/api/pagination";
import type { Paginated, Review, ReviewPage } from "@/types/api";

export type ReviewWriteInput = {
  rating: number;
  comment: string;
  photoIds?: string[];
};

export const reviewsApi = {
  list: async (
    productId: string,
    params?: { page?: number; size?: number; sortBy?: string },
  ): Promise<ReviewPage> => {
    const raw = await apiClient<{
      summary: ReviewPage["summary"];
      reviews: unknown;
    }>(`products/${productId}/reviews`, { params });

    const reviews = normalizePaginated<Review>(raw.reviews);
    return { summary: raw.summary, reviews };
  },

  create: (productId: string, input: ReviewWriteInput) =>
    apiClient<Review>(`products/${productId}/reviews`, {
      method: "POST",
      body: input,
    }),

  update: (productId: string, reviewId: string, input: ReviewWriteInput) =>
    apiClient<Review>(`products/${productId}/reviews/${reviewId}`, {
      method: "PUT",
      body: input,
    }),

  delete: (productId: string, reviewId: string) =>
    apiClient<null>(`products/${productId}/reviews/${reviewId}`, {
      method: "DELETE",
    }),
};
