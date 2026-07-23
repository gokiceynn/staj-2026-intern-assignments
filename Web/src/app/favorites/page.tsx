"use client";

import Link from "next/link";
import { useFavoritesList } from "@/features/favorites/queries/use-favorites";
import { ProductGrid } from "@/components/product/ProductGrid";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { ApiError } from "@/lib/api/envelope";

export default function FavoritesPage() {
  const { data, isLoading, error, refetch } = useFavoritesList({
    page: 1,
    size: 48,
  });

  if (error) {
    return (
      <ErrorState
        message={
          error instanceof ApiError ? error.message : "Favoriler yüklenemedi"
        }
        onRetry={() => refetch()}
      />
    );
  }

  const items = data?.items ?? [];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Favorilerim</h1>

      {!isLoading && items.length === 0 ? (
        <EmptyState
          title="Favori ürün yok"
          description="Beğendiğiniz ürünleri favorilere ekleyin."
          action={
            <Link
              href="/products"
              className="inline-flex h-10 items-center justify-center rounded-md bg-brand-600 px-4 text-sm font-medium text-white hover:bg-brand-700"
            >
              Ürünlere Git
            </Link>
          }
        />
      ) : (
        <ProductGrid products={items} loading={isLoading} />
      )}
    </div>
  );
}
