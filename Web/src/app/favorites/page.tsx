"use client";

import Link from "next/link";
import { useFavorites } from "@/features/favorites/queries/use-favorites";
import { useProducts } from "@/features/products/queries/use-products";
import { ProductGrid } from "@/components/product/ProductGrid";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";

export default function FavoritesPage() {
  const { ids, isDevOnly, isAvailable } = useFavorites();
  const { data, isLoading } = useProducts({ page: 1, size: 100 });

  const favoriteProducts =
    data?.items.filter((p) => ids.includes(p.id)) ?? [];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Favorilerim</h1>

      {isDevOnly && (
        <p className="rounded-md border border-yellow-300 bg-yellow-50 p-3 text-sm text-yellow-800 dark:bg-yellow-950 dark:text-yellow-100">
          Favoriler yalnızca development ortamında localStorage ile saklanır.
          Backend API sözleşmesinde favori endpoint&apos;i bulunmamaktadır.
        </p>
      )}

      {!isAvailable ? (
        <EmptyState
          title="Favoriler kullanılamıyor"
          description="Production ortamında favori kalıcılığı backend API gelene kadar devre dışıdır."
          action={
            <Button onClick={() => window.location.assign("/products")}>
              Ürünlere Git
            </Button>
          }
        />
      ) : favoriteProducts.length === 0 && !isLoading ? (
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
        <ProductGrid products={favoriteProducts} loading={isLoading} />
      )}
    </div>
  );
}
