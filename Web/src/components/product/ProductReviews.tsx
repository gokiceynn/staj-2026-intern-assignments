"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import {
  useCreateReview,
  useDeleteReview,
  useProductReviews,
  useUpdateReview,
} from "@/features/reviews/queries/use-reviews";
import { photosApi } from "@/features/photos/api/photos-api";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Rating } from "@/components/ui/Rating";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";
import { getAuthErrorMessage } from "@/lib/api/auth-errors";
import { formatDate } from "@/lib/utils/format";

const reviewSchema = z.object({
  rating: z.coerce.number().min(1).max(5),
  comment: z.string().min(3, "Yorum en az 3 karakter olmalı"),
});

type ReviewFormInput = z.infer<typeof reviewSchema>;

type ProductReviewsProps = {
  productId: string;
};

export function ProductReviews({ productId }: ProductReviewsProps) {
  const { data: user } = useCurrentUser();
  const { data, isLoading } = useProductReviews(productId);
  const createReview = useCreateReview(productId);
  const updateReview = useUpdateReview(productId);
  const deleteReview = useDeleteReview(productId);
  const { showToast } = useToast();
  const [editingId, setEditingId] = useState<string | null>(null);
  const [photoIds, setPhotoIds] = useState<string[]>([]);

  const form = useForm<ReviewFormInput>({
    resolver: zodResolver(reviewSchema),
    defaultValues: { rating: 5, comment: "" },
  });

  const onSubmit = async (input: ReviewFormInput) => {
    try {
      if (editingId) {
        await updateReview.mutateAsync({
          reviewId: editingId,
          input: { ...input, photoIds },
        });
        showToast("Yorum güncellendi", "success");
        setEditingId(null);
      } else {
        await createReview.mutateAsync({ ...input, photoIds });
        showToast("Yorum eklendi", "success");
      }
      form.reset({ rating: 5, comment: "" });
      setPhotoIds([]);
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          form.setError(field as keyof ReviewFormInput, {
            message: messages[0],
          });
        }
      }
      showToast(getAuthErrorMessage(err, "Yorum kaydedilemedi"), "error");
    }
  };

  const handlePhoto = async (file: File | null) => {
    if (!file) return;
    try {
      const result = await photosApi.upload(file);
      setPhotoIds((prev) => [...prev, result.photoId]);
      showToast("Fotoğraf yüklendi", "success");
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Fotoğraf yüklenemedi",
        "error",
      );
    }
  };

  if (isLoading) return <Skeleton className="h-40 w-full" />;

  return (
    <section className="mt-10 space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold">Değerlendirmeler</h2>
        {data?.summary && (
          <div className="flex items-center gap-2 text-sm text-text-muted">
            <Rating value={data.summary.averageRating} />
            <span>({data.summary.totalReviewCount} yorum)</span>
          </div>
        )}
      </div>

      {user?.role === "Customer" && (
        <form
          onSubmit={form.handleSubmit(onSubmit)}
          className="space-y-3 rounded-lg border border-border bg-surface p-4"
        >
          <h3 className="font-semibold">
            {editingId ? "Yorumu düzenle" : "Yorum yaz"}
          </h3>
          <Input
            label="Puan (1-5)"
            type="number"
            min={1}
            max={5}
            error={form.formState.errors.rating?.message}
            {...form.register("rating")}
          />
          <div>
            <label className="mb-1 block text-sm font-medium">Yorum</label>
            <textarea
              className="w-full rounded-lg border border-border px-3 py-2 text-sm"
              rows={3}
              {...form.register("comment")}
            />
            {form.formState.errors.comment && (
              <p className="mt-1 text-sm text-danger">
                {form.formState.errors.comment.message}
              </p>
            )}
          </div>
          <Input
            label="Fotoğraf ekle (isteğe bağlı)"
            type="file"
            accept="image/*"
            onChange={(e) => handlePhoto(e.target.files?.[0] ?? null)}
          />
          {photoIds.length > 0 && (
            <p className="text-xs text-text-muted">
              {photoIds.length} fotoğraf eklendi
            </p>
          )}
          <div className="flex gap-2">
            <Button type="submit" loading={createReview.isPending || updateReview.isPending}>
              {editingId ? "Güncelle" : "Gönder"}
            </Button>
            {editingId && (
              <Button type="button" variant="outline" onClick={() => setEditingId(null)}>
                İptal
              </Button>
            )}
          </div>
        </form>
      )}

      <div className="space-y-4">
        {data?.reviews.items.map((review) => (
          <article
            key={review.id}
            className="rounded-lg border border-border bg-surface p-4"
          >
            <div className="mb-2 flex items-center justify-between">
              <div>
                <p className="font-medium">{review.user.displayName}</p>
                <p className="text-xs text-text-muted">
                  {formatDate(review.createdAt)}
                  {review.isVerifiedPurchase && " · Doğrulanmış alışveriş"}
                </p>
              </div>
              <Rating value={review.rating} />
            </div>
            <p className="text-sm text-text-muted">{review.comment}</p>
            {user?.id === review.user.id && (
              <div className="mt-3 flex gap-2">
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => {
                    setEditingId(review.id);
                    form.reset({
                      rating: review.rating,
                      comment: review.comment,
                    });
                    setPhotoIds(review.photos.map((p) => p.photoId));
                  }}
                >
                  Düzenle
                </Button>
                <Button
                  size="sm"
                  variant="danger"
                  loading={deleteReview.isPending}
                  onClick={async () => {
                    try {
                      await deleteReview.mutateAsync(review.id);
                      showToast("Yorum silindi", "success");
                    } catch (err) {
                      showToast(
                        err instanceof ApiError ? err.message : "Silinemedi",
                        "error",
                      );
                    }
                  }}
                >
                  Sil
                </Button>
              </div>
            )}
          </article>
        ))}
        {data?.reviews.items.length === 0 && (
          <p className="text-sm text-text-muted">Henüz yorum yok.</p>
        )}
      </div>
    </section>
  );
}
