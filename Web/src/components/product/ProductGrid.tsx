import { ProductCard } from "@/components/product/ProductCard";
import { ProductCardSkeleton } from "@/components/ui/Skeleton";
import type { ProductListItem } from "@/types/api";

type ProductGridProps = {
  products: ProductListItem[];
  loading?: boolean;
  onAddToCart?: (productId: string) => void;
  addingId?: string;
  getDiscountPercent?: (product: ProductListItem) => number | undefined;
  showRemoveFavorite?: boolean;
};

export function ProductGrid({
  products,
  loading,
  onAddToCart,
  addingId,
  getDiscountPercent,
  showRemoveFavorite,
}: ProductGridProps) {
  if (loading) {
    return (
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
        {Array.from({ length: 8 }).map((_, i) => (
          <ProductCardSkeleton key={i} />
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
      {products.map((product) => (
        <ProductCard
          key={product.id}
          product={product}
          onAddToCart={onAddToCart}
          adding={addingId === product.id}
          discountPercent={getDiscountPercent?.(product)}
          showRemoveFavorite={showRemoveFavorite}
        />
      ))}
    </div>
  );
}
