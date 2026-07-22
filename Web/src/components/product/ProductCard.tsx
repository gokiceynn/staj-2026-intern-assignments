"use client";

import Image from "next/image";
import Link from "next/link";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { HeartIcon, CartIcon } from "@/components/ui/icons";
import { useFavorites } from "@/features/favorites/queries/use-favorites";
import type { ProductListItem } from "@/types/api";
import { cn } from "@/lib/utils/cn";

function discountPercent(product: ProductListItem, override?: number) {
  if (override && override > 0) return override;
  if (
    product.originalPrice != null &&
    product.originalPrice > product.price
  ) {
    return Math.round(100 * (1 - product.price / product.originalPrice));
  }
  return 0;
}

type ProductCardProps = {
  product: ProductListItem;
  onAddToCart?: (productId: string) => void;
  adding?: boolean;
  discountPercent?: number;
  showRemoveFavorite?: boolean;
  variant?: "grid" | "rail";
};

export function ProductCard({
  product,
  onAddToCart,
  adding,
  discountPercent: discountOverride,
  showRemoveFavorite = false,
  variant = "grid",
}: ProductCardProps) {
  const isRail = variant === "rail";
  const { toggle, has, remove, isAvailable, isPending } = useFavorites();
  const isFavorite = has(product.id);
  const lowStock = product.stock > 0 && product.stock <= 5;
  const discount = discountPercent(product, discountOverride);
  const hasDiscount = discount > 0;
  const freeShipping =
    product.freeShipping ?? (hasDiscount ? product.price : product.price) >= 500;

  return (
    <article
      className={cn(
        "group relative flex h-full flex-col overflow-hidden rounded-xl border border-border bg-surface shadow-card transition-all hover:border-brand-200 hover:shadow-md",
        isRail && "shadow-sm",
      )}
    >
      {hasDiscount && (
        <Badge className="absolute left-2 top-2 z-10 bg-deal text-white">
          %{discount} İndirim
        </Badge>
      )}

      <Link
        href={`/products/${product.id}`}
        className="relative aspect-square overflow-hidden bg-surface-muted"
      >
        <Image
          src={product.photoUrl}
          alt={product.title}
          fill
          className={cn(
            "transition-transform duration-300 group-hover:scale-105",
            isRail ? "object-cover" : "object-contain p-3",
          )}
          sizes="(max-width: 768px) 50vw, 25vw"
        />
        {product.stock === 0 && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/40">
            <span className="rounded-lg bg-black/60 px-2.5 py-1 text-xs font-bold text-white">
              Tükendi
            </span>
          </div>
        )}
      </Link>

      {isAvailable && (
        <button
          type="button"
          onClick={() => toggle(product.id)}
          disabled={isPending}
          className={cn(
            "absolute right-2 top-2 z-10 flex h-9 w-9 items-center justify-center rounded-full bg-surface/95 shadow-sm transition hover:bg-surface-muted disabled:opacity-60",
            isFavorite ? "text-red-500" : "text-text-muted hover:text-red-400",
          )}
          aria-label={isFavorite ? "Favorilerden çıkar" : "Favorilere ekle"}
        >
          <HeartIcon className="h-5 w-5" filled={isFavorite} />
        </button>
      )}

      <div className={cn("flex flex-1 flex-col gap-1", isRail ? "p-2.5" : "p-3")}>
        <Link href={`/products/${product.id}`}>
          <h3
            className={cn(
              "line-clamp-2 leading-snug hover:text-brand-600",
              isRail ? "text-[12.5px]" : "text-sm",
            )}
          >
            {product.brand ? (
              <>
                <span className="font-extrabold text-text">{product.brand} </span>
                <span className="text-text-muted">{product.title}</span>
              </>
            ) : (
              <span className="text-text">{product.title}</span>
            )}
          </h3>
        </Link>

        <div
          className={cn(
            "flex items-center gap-1 text-text-muted",
            isRail ? "text-[11px]" : "text-xs",
          )}
        >
          <span className="text-amber-500">★</span>
          <span className="font-medium text-text">{product.rating.toFixed(1)}</span>
          {product.reviewCount != null && (
            <span className="truncate">({product.reviewCount.toLocaleString("tr-TR")})</span>
          )}
        </div>

        <div className="mt-auto flex items-end justify-between gap-2 pt-1">
          <div>
            {hasDiscount ? (
              <div className="flex flex-col gap-0.5">
                <span className="text-xs text-text-muted line-through">
                  {new Intl.NumberFormat("tr-TR", {
                    style: "currency",
                    currency: "TRY",
                  }).format(product.originalPrice!)}
                </span>
                <Price
                  amount={product.price}
                  size={isRail ? "md" : "lg"}
                  className="text-success"
                />
              </div>
            ) : (
              <Price
                amount={product.price}
                size={isRail ? "md" : "lg"}
                className={isRail ? "text-success" : undefined}
              />
            )}
            {(freeShipping || lowStock) && (
              <div className="mt-1 flex flex-wrap gap-x-2 gap-y-0.5 text-[11px] font-bold">
                {freeShipping && (
                  <span className="text-success">Kargo Bedava</span>
                )}
                {lowStock && (
                  <span className="text-deal">Son {product.stock} ürün!</span>
                )}
              </div>
            )}
          </div>

          {onAddToCart && product.stock > 0 && (
            <button
              type="button"
              onClick={() => onAddToCart(product.id)}
              disabled={adding}
              className={cn(
                "flex shrink-0 items-center justify-center rounded-full bg-brand-50 text-brand-600 transition hover:bg-brand-500 hover:text-white disabled:opacity-50",
                isRail ? "h-8 w-8" : "h-10 w-10",
              )}
              aria-label="Sepete ekle"
            >
              {adding ? (
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
              ) : (
                <CartIcon className="h-5 w-5" />
              )}
            </button>
          )}
        </div>

        {showRemoveFavorite && isAvailable && (
          <button
            type="button"
            onClick={() => remove(product.id)}
            disabled={isPending}
            className="mt-2 w-full rounded-md border border-red-200 py-2 text-xs font-medium text-red-500 transition hover:bg-red-50 disabled:opacity-60 dark:border-red-900/50 dark:hover:bg-red-950/30"
          >
            Favorilerden çıkar
          </button>
        )}
      </div>
    </article>
  );
}
