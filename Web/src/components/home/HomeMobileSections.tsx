"use client";

import type { ProductListItem } from "@/types/api";
import { PromoBannerCarousel } from "@/components/home/PromoBannerCarousel";
import { MobileCategoryStrip } from "@/components/home/MobileCategoryStrip";
import { SectionHeader } from "@/components/home/SectionHeader";
import { ProductRail } from "@/components/home/ProductRail";
import { ProductGrid } from "@/components/product/ProductGrid";

type HomeMobileSectionsProps = {
  flashDeals: ProductListItem[];
  featured: ProductListItem[];
  topRated: ProductListItem[];
};

export function HomeMobileSections({
  flashDeals,
  featured,
  topRated,
}: HomeMobileSectionsProps) {
  return (
    <div className="space-y-2 pb-2 md:hidden">
      <PromoBannerCarousel />
      <MobileCategoryStrip />

      {flashDeals.length > 0 && (
        <>
          <SectionHeader
            title="⚡ Süper Fırsatlar"
            href="/products?sortBy=price_asc"
          />
          <ProductRail products={flashDeals} />
        </>
      )}

      {featured.length > 0 && (
        <>
          <SectionHeader title="Öne Çıkanlar" href="/products" />
          <ProductRail products={featured} />
        </>
      )}

      {topRated.length > 0 && (
        <>
          <SectionHeader
            title="En Beğenilenler"
            href="/products?sortBy=rating_desc"
          />
          <div className="px-4 py-2">
            <ProductGrid products={topRated} />
          </div>
        </>
      )}
    </div>
  );
}
