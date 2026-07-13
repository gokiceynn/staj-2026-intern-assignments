"use client";

import Image from "next/image";
import Link from "next/link";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { HeartIcon, CartIcon } from "@/components/ui/icons";
import { useFavorites } from "@/features/favorites/queries/use-favorites";
import type { ProductListItem } from "@/types/api";
import { cn } from "@/lib/utils/cn";

type ProductCardProps = {
  product: ProductListItem;
  onAddToCart?: (productId: string) => void;
  adding?: boolean;
};

export function ProductCard({ product, onAddToCart, adding }: ProductCardProps) {
  const { toggle, has, isAvailable } = useFavorites();
  const lowStock = product.stock > 0 && product.stock <= 5;
  const freeShipping = product.price >= 500;

  return (
    <article className="group relative flex flex-col overflow-hidden rounded-xl border border-border bg-surface shadow-card transition-all hover:border-brand-200 hover:shadow-md">
      {freeShipping && (
        <Badge className="absolute left-2 top-2 z-10 bg-success/90 text-white">
          Kargo Bedava
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
          className="object-contain p-3 transition-transform duration-300 group-hover:scale-105"
          sizes="(max-width: 768px) 50vw, 25vw"
        />
      </Link>

      {isAvailable && (
        <button
          type="button"
          onClick={() => toggle(product.id)}
          className={cn(
            "absolute right-2 top-2 z-10 flex h-9 w-9 items-center justify-center rounded-full bg-white/90 shadow-sm transition hover:bg-white",
            has(product.id) ? "text-deal" : "text-text-muted",
          )}
          aria-label={has(product.id) ? "Favorilerden çıkar" : "Favorilere ekle"}
        >
          <HeartIcon className="h-5 w-5" filled={has(product.id)} />
        </button>
      )}

      <div className="flex flex-1 flex-col gap-1.5 p-3">
        <Link href={`/products/${product.id}`}>
          <h3 className="line-clamp-2 text-sm leading-snug text-text hover:text-brand-600">
            {product.title}
          </h3>
        </Link>

        <div className="flex items-center gap-1 text-xs text-text-muted">
          <span className="text-amber-500">★</span>
          <span className="font-medium text-text">{product.rating.toFixed(1)}</span>
          <span>·</span>
          <span className="truncate">{product.category.name}</span>
        </div>

        <div className="mt-auto flex items-end justify-between gap-2 pt-1">
          <div>
            <Price amount={product.price} size="lg" />
            {lowStock && (
              <p className="text-xs font-medium text-deal">Son {product.stock} ürün!</p>
            )}
            {product.stock === 0 && (
              <p className="text-xs font-medium text-danger">Stokta yok</p>
            )}
          </div>

          {onAddToCart && product.stock > 0 && (
            <button
              type="button"
              onClick={() => onAddToCart(product.id)}
              disabled={adding}
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-50 text-brand-600 transition hover:bg-brand-500 hover:text-white disabled:opacity-50"
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
      </div>
    </article>
  );
}
