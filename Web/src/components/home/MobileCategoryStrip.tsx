"use client";

import Link from "next/link";
import { useCategories } from "@/features/categories/queries/use-categories";
import { Skeleton } from "@/components/ui/Skeleton";

const CATEGORY_EMOJI: Record<string, string> = {
  Elektronik: "📱",
  Moda: "👗",
  "Ev & Yaşam": "🏠",
  Kozmetik: "💄",
  Süpermarket: "🛒",
  "Spor & Outdoor": "⚽",
  "Kitap & Hobi": "📚",
  "Anne & Bebek": "👶",
};

function emojiForCategory(name: string) {
  return CATEGORY_EMOJI[name] ?? "🏷️";
}

export function MobileCategoryStrip() {
  const { data: categories, isLoading } = useCategories();

  if (isLoading) {
    return (
      <div className="flex gap-3 overflow-hidden px-4 py-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="flex w-16 shrink-0 flex-col items-center gap-1">
            <Skeleton className="h-12 w-12 rounded-full" />
            <Skeleton className="h-2 w-12" />
          </div>
        ))}
      </div>
    );
  }

  if (!categories?.length) return null;

  return (
    <nav aria-label="Kategoriler" className="py-2">
      <ul className="scrollbar-hide flex gap-3.5 overflow-x-auto px-4">
        {categories.map((category) => (
          <li key={category.id} className="w-16 shrink-0">
            <Link
              href={`/products?categoryId=${category.id}`}
              className="flex flex-col items-center gap-1 text-center"
            >
              <span className="flex h-12 w-12 items-center justify-center rounded-full bg-brand-500/10 text-xl">
                {emojiForCategory(category.name)}
              </span>
              <span className="line-clamp-2 text-[10.5px] leading-tight text-text">
                {category.name}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
