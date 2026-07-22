import { HeroPromo } from "@/components/home/HeroPromo";
import { FeaturedProducts } from "@/components/home/FeaturedProducts";
import { HomeMobileSections } from "@/components/home/HomeMobileSections";
import { fetchPublic, productListPath } from "@/lib/api/server";
import { normalizePaginated } from "@/lib/api/pagination";
import { withPhotoUrls } from "@/lib/utils/photo-url";
import type { ProductListItem } from "@/types/api";

export default async function HomePage() {
  let popular: ProductListItem[] = [];
  let rated: ProductListItem[] = [];
  let flashDeals: ProductListItem[] = [];

  try {
    const [popularData, ratedData, flashData] = await Promise.all([
      fetchPublic<unknown>(productListPath({ page: 1, size: 8 })),
      fetchPublic<unknown>(
        productListPath({ page: 1, size: 8, sortBy: "rating_desc" }),
      ),
      fetchPublic<unknown>(
        productListPath({ page: 1, size: 8, sortBy: "price_asc" }),
      ),
    ]);
    popular = withPhotoUrls(normalizePaginated<ProductListItem>(popularData).items);
    rated = withPhotoUrls(normalizePaginated<ProductListItem>(ratedData).items);
    flashDeals = withPhotoUrls(normalizePaginated<ProductListItem>(flashData).items);
  } catch {
    // Backend yoksa boş grid + statik kampanyalar gösterilir
  }

  return (
    <>
      <HomeMobileSections
        flashDeals={flashDeals}
        featured={popular}
        topRated={rated}
      />

      <div className="hidden space-y-6 md:block md:space-y-8">
        <HeroPromo />

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
    </>
  );
}
