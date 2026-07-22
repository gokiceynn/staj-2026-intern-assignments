"use client";

import Image from "next/image";
import { useParams } from "next/navigation";
import { useState } from "react";
import { useProduct } from "@/features/products/queries/use-products";
import { useAddToCart } from "@/features/cart/queries/use-cart";
import { useFavorites } from "@/features/favorites/queries/use-favorites";
import { Price } from "@/components/ui/Price";
import { Rating } from "@/components/ui/Rating";
import { Button } from "@/components/ui/Button";
import { QuantitySelector } from "@/components/ui/QuantitySelector";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";
import { ProductReviews } from "@/components/product/ProductReviews";

export default function ProductDetailPage() {
  const params = useParams<{ id: string }>();
  const { data: product, isLoading, error, refetch } = useProduct(params.id);
  const addToCart = useAddToCart();
  const { toggle, has, isAvailable } = useFavorites();
  const { showToast } = useToast();
  const [quantity, setQuantity] = useState(1);

  if (isLoading) {
    return (
      <div className="grid gap-8 md:grid-cols-2">
        <Skeleton className="aspect-square w-full" />
        <div className="space-y-4">
          <Skeleton className="h-8 w-3/4" />
          <Skeleton className="h-4 w-1/2" />
          <Skeleton className="h-10 w-32" />
        </div>
      </div>
    );
  }

  if (error || !product) {
    return (
      <ErrorState
        message={
          error instanceof ApiError ? error.message : "Ürün bulunamadı"
        }
        onRetry={() => refetch()}
      />
    );
  }

  const handleAddToCart = async () => {
    try {
      await addToCart.mutateAsync({
        productId: product.id,
        quantity,
      });
      showToast("Ürün sepete eklendi", "success");
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Sepete eklenemedi",
        "error",
      );
    }
  };

  return (
    <div className="grid gap-8 md:grid-cols-2">
      <div className="relative aspect-square overflow-hidden rounded-lg border border-border">
        <Image
          src={product.photoUrl}
          alt={product.title}
          fill
          className="object-cover"
          priority
          sizes="(max-width: 768px) 100vw, 50vw"
        />
      </div>

      <div className="space-y-4">
        <h1 className="text-2xl font-bold">{product.title}</h1>
        <Rating value={product.rating} />
        <Price amount={product.price} size="lg" />
        <p className="text-sm text-text-muted">
          Stok: {product.stock > 0 ? product.stock : "Tükendi"}
        </p>
        <p className="text-text-muted">{product.description}</p>

        {Object.keys(product.features).length > 0 && (
          <dl className="space-y-1 text-sm">
            {Object.entries(product.features).map(([key, value]) => (
              <div key={key} className="flex gap-2">
                <dt className="font-medium">{key}:</dt>
                <dd className="text-text-muted">{value}</dd>
              </div>
            ))}
          </dl>
        )}

        <div className="flex items-center gap-4 pt-4">
          <QuantitySelector
            value={quantity}
            max={product.stock}
            onChange={setQuantity}
            disabled={product.stock === 0}
          />
          <Button
            onClick={handleAddToCart}
            loading={addToCart.isPending}
            disabled={product.stock === 0}
          >
            Sepete Ekle
          </Button>
          {isAvailable && (
            <Button variant="outline" onClick={() => toggle(product.id)}>
              {has(product.id) ? "♥ Favoride" : "♡ Favorile"}
            </Button>
          )}
        </div>
      </div>

      <ProductReviews productId={product.id} />
    </div>
  );
}
