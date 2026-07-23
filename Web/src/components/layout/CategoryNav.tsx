"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import type { CategoryRef } from "@/types/api";
import { cn } from "@/lib/utils/cn";

const FALLBACK_CATEGORIES: CategoryRef[] = [
  { id: "cat_electronics", name: "Elektronik" },
  { id: "cat_fashion", name: "Moda" },
  { id: "cat_home", name: "Ev & Yaşam" },
  { id: "cat_sports", name: "Spor" },
  { id: "cat_beauty", name: "Kozmetik" },
  { id: "cat_books", name: "Kitap" },
  { id: "cat_toys", name: "Oyuncak" },
  { id: "cat_auto", name: "Oto & Bahçe" },
];

type CategoryNavProps = {
  categories?: CategoryRef[];
};

function navLinkClass(active: boolean) {
  return cn(
    "shrink-0 rounded-full px-4 py-1.5 text-sm font-medium transition-colors",
    active
      ? "bg-brand-50 text-brand-600"
      : "text-text-muted hover:bg-surface-muted hover:text-brand-600",
  );
}

export function CategoryNav({ categories }: CategoryNavProps) {
  const searchParams = useSearchParams();
  const activeCategoryId = searchParams.get("categoryId");
  const hasSearch = Boolean(searchParams.get("q")?.trim());

  const items =
    categories && categories.length > 0 ? categories : FALLBACK_CATEGORIES;
  const useCategoryIds = categories && categories.length > 0;

  return (
    <nav
      aria-label="Kategoriler"
      className="border-t border-border bg-surface"
    >
      <div className="mx-auto flex max-w-7xl items-center gap-1 overflow-x-auto px-4 py-2 scrollbar-hide">
        <Link
          href="/products"
          className={navLinkClass(!activeCategoryId && !hasSearch)}
        >
          Tüm Ürünler
        </Link>
        {items.map((cat) => (
          <Link
            key={cat.id}
            href={
              useCategoryIds
                ? `/products?categoryId=${cat.id}`
                : `/products?q=${encodeURIComponent(cat.name)}`
            }
            className={navLinkClass(activeCategoryId === cat.id)}
          >
            {cat.name}
          </Link>
        ))}
      </div>
    </nav>
  );
}
