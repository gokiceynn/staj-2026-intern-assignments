import { HeroPromo } from "@/components/home/HeroPromo";
import { QuickDealStrip } from "@/components/home/QuickDealStrip";
import { FeaturedProducts } from "@/components/home/FeaturedProducts";
import { fetchPublic, productListPath } from "@/lib/api/server";
import { normalizePaginated } from "@/lib/api/pagination";
import { withPhotoUrls } from "@/lib/utils/photo-url";
import type { ProductListItem } from "@/types/api";

export default async function HomePage() {
  let popular: ProductListItem[] = [];
  let rated: ProductListItem[] = [];

  try {
    const [popularData, ratedData] = await Promise.all([
      fetchPublic<unknown>(productListPath({ page: 1, size: 8 })),
      fetchPublic<unknown>(
        productListPath({ page: 1, size: 4, sortBy: "rating_desc" }),
      ),
    ]);
    popular = withPhotoUrls(normalizePaginated<ProductListItem>(popularData).items);
    rated = withPhotoUrls(normalizePaginated<ProductListItem>(ratedData).items);
  } catch {
    // Backend yoksa boş grid + statik kampanyalar gösterilir
  }

  return (
    <div className="space-y-6 md:space-y-8">
      <HeroPromo />
      <QuickDealStrip />

      <FeaturedProducts
        title="Popüler Ürünlerden Seçtik"
        products={popular}
        viewAllHref="/products"
      />

      {rated.length > 0 && (
        <FeaturedProducts
          title="En Beğenilenler"
          products={rated}
          viewAllHref="/products?sortBy=rating_desc"
        />
      )}

      {popular.length === 0 && rated.length === 0 && (
        <section className="rounded-xl border border-dashed border-border bg-surface p-12 text-center">
          <p className="text-lg font-medium">Ürünler yüklenemedi</p>
          <p className="mt-2 text-sm text-text-muted">
            Backend API çalıştığında ürünler burada listelenecek.
          </p>
        </section>
      )}
    </div>
  );
}
