"use client";

import { ProductCard } from "@/components/product/ProductCard";
import { Skeleton } from "@/components/ui/Skeleton";
import type { ProductListItem } from "@/types/api";

type ProductRailProps = {
  products: ProductListItem[];
  loading?: boolean;
};

export function ProductRail({ products, loading }: ProductRailProps) {
  if (loading) {
    return (
      <div className="flex gap-3 overflow-hidden px-4 py-2">
        {Array.from({ length: 3 }).map((_, i) => (
          <Skeleton key={i} className="h-[300px] w-[165px] shrink-0 rounded-xl" />
        ))}
      </div>
    );
  }

  if (products.length === 0) return null;

  return (
    <div className="scrollbar-hide flex gap-3 overflow-x-auto px-4 py-2">
      {products.map((product) => (
        <div key={product.id} className="h-[300px] w-[165px] shrink-0">
          <ProductCard product={product} variant="rail" />
        </div>
      ))}
    </div>
  );
}
