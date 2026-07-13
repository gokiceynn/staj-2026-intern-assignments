import Link from "next/link";
import type { CategoryRef } from "@/types/api";

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

export function CategoryNav({ categories }: CategoryNavProps) {
  const items =
    categories && categories.length > 0 ? categories : FALLBACK_CATEGORIES;

  return (
    <nav
      aria-label="Kategoriler"
      className="border-t border-border bg-surface"
    >
      <div className="mx-auto flex max-w-7xl items-center gap-1 overflow-x-auto px-4 py-2 scrollbar-hide">
        <Link
          href="/products"
          className="shrink-0 rounded-full bg-brand-50 px-4 py-1.5 text-sm font-medium text-brand-600 hover:bg-brand-100"
        >
          Tüm Ürünler
        </Link>
        {items.map((cat) => (
          <Link
            key={cat.id}
            href={`/products?categoryId=${cat.id}`}
            className="shrink-0 rounded-full px-4 py-1.5 text-sm text-text-muted transition-colors hover:bg-surface-muted hover:text-brand-600"
          >
            {cat.name}
          </Link>
        ))}
      </div>
    </nav>
  );
}
