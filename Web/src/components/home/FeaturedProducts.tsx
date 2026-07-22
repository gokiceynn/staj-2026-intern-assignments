"use client";

import { useState } from "react";
import Link from "next/link";
import { ProductGrid } from "@/components/product/ProductGrid";
import { useAddToCart } from "@/features/cart/queries/use-cart";
import { useToast } from "@/components/ui/toast-context";
import type { ProductListItem } from "@/types/api";

type FeaturedProductsProps = {
  title: string;
  products: ProductListItem[];
  viewAllHref?: string;
};

export function FeaturedProducts({
  title,
  products,
  viewAllHref = "/products",
}: FeaturedProductsProps) {
  const addToCart = useAddToCart();
  const { showToast } = useToast();
  const [addingId, setAddingId] = useState<string>();

  const handleAddToCart = async (productId: string) => {
    const product = products.find((item) => item.id === productId);
    setAddingId(productId);
    try {
      await addToCart.mutateAsync({
        productId,
        quantity: 1,
        product: product
          ? {
              productTitle: product.title,
              price: product.price,
              photoUrl: product.photoUrl,
              photoId: product.photoId,
              stock: product.stock,
            }
          : undefined,
      });
      showToast("Ürün sepete eklendi", "success");
    } catch {
      // Hata toast'ı useAddToCart içinde gösteriliyor
    } finally {
      setAddingId(undefined);
    }
  };

  if (products.length === 0) return null;

  return (
    <section className="rounded-xl border border-border bg-surface p-4 shadow-card md:p-6">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="text-lg font-bold md:text-xl">{title}</h2>
        <Link
          href={viewAllHref}
          className="text-sm font-medium text-brand-600 hover:underline"
        >
          Tümünü Gör →
        </Link>
      </div>
      <ProductGrid
        products={products}
        onAddToCart={handleAddToCart}
        addingId={addingId}
      />
    </section>
  );
}
