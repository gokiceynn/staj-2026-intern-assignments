"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useMemo, useState } from "react";
import { ProductGrid } from "@/components/product/ProductGrid";
import { Pagination } from "@/components/ui/Pagination";
import { Select } from "@/components/ui/Select";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { ErrorState } from "@/components/ui/ErrorState";
import { EmptyState } from "@/components/ui/EmptyState";
import { PetDealBanner } from "@/components/campaign/PetDealBanner";
import { useProducts } from "@/features/products/queries/use-products";
import { useRootCategories } from "@/features/categories/queries/use-categories";
import { useAddToCart } from "@/features/cart/queries/use-cart";
import { useToast } from "@/components/ui/toast-context";
import { parseProductSearchParams } from "@/lib/utils/query-params";
import {
  filterPetProducts,
  getPetDealDiscountPercent,
  PET_DEAL_CAMPAIGN,
} from "@/lib/campaigns/pet-deal";
import { ApiError } from "@/lib/api/envelope";
import type { ProductListItem, ProductSortBy } from "@/types/api";

function ProductsContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const campaign = searchParams.get("campaign");
  const isPetDeal = campaign === PET_DEAL_CAMPAIGN.id;

  const params = parseProductSearchParams(
    Object.fromEntries(searchParams.entries()),
  );

  const queryParams = isPetDeal
    ? {
        page: 1,
        size: 50,
        categoryId: PET_DEAL_CAMPAIGN.categoryId,
        sortBy: "price_asc" as ProductSortBy,
      }
    : params;

  const [q, setQ] = useState(params.q ?? "");
  const { data, isLoading, error, refetch } = useProducts(queryParams);
  const { data: categories } = useRootCategories();
  const addToCart = useAddToCart();
  const { showToast } = useToast();
  const [addingId, setAddingId] = useState<string>();

  const petProducts = useMemo(() => {
    if (!data?.items) return [];
    if (!isPetDeal) return data.items;
    return filterPetProducts(data.items);
  }, [data?.items, isPetDeal]);

  const displayProducts = isPetDeal ? petProducts : (data?.items ?? []);
  const totalCount = isPetDeal ? petProducts.length : (data?.totalCount ?? 0);

  const getDiscountPercent = isPetDeal
    ? (product: ProductListItem) => getPetDealDiscountPercent(product.id)
    : undefined;

  const updateParams = (updates: Record<string, string | undefined>) => {
    const sp = new URLSearchParams(searchParams.toString());
    for (const [key, value] of Object.entries(updates)) {
      if (value) sp.set(key, value);
      else sp.delete(key);
    }
    router.push(`/products?${sp.toString()}`);
  };

  const handleAddToCart = async (productId: string) => {
    setAddingId(productId);
    try {
      await addToCart.mutateAsync({ productId, quantity: 1 });
      showToast("Ürün sepete eklendi", "success");
    } catch (err) {
      const msg = err instanceof ApiError ? err.message : "Sepete eklenemedi";
      showToast(msg, "error");
    } finally {
      setAddingId(undefined);
    }
  };

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Ürünler yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  const activeCategory = categories?.find((c) => c.id === params.categoryId);
  const pageTitle = isPetDeal
    ? PET_DEAL_CAMPAIGN.title
    : (activeCategory?.name ?? (params.q ? `"${params.q}" araması` : "Tüm Ürünler"));

  return (
    <div className="space-y-6">
      {isPetDeal && <PetDealBanner />}

      <div className="rounded-xl border border-border bg-surface p-4 shadow-card md:p-6">
        <h1 className="text-xl font-bold md:text-2xl">{pageTitle}</h1>
        <p className="mt-1 text-sm text-text-muted">
          {isLoading
            ? "Ürünler yükleniyor..."
            : `${totalCount} ürün listeleniyor`}
        </p>

        {!isPetDeal && (
        <div className="mt-4 flex flex-col gap-3 lg:flex-row lg:items-end">
        <form
          className="flex flex-1 gap-2"
          onSubmit={(e) => {
            e.preventDefault();
            updateParams({ q: q || undefined, page: "1" });
          }}
        >
          <div className="flex flex-1 overflow-hidden rounded-lg border-2 border-brand-500">
            <Input
              placeholder="Ürün, kategori veya marka ara..."
              value={q}
              onChange={(e) => setQ(e.target.value)}
              className="flex-1 border-0 focus-visible:ring-0"
            />
            <Button type="submit" className="rounded-none px-5">
              Ara
            </Button>
          </div>
        </form>

        <Select
          label="Kategori"
          value={params.categoryId ?? ""}
          onChange={(e) =>
            updateParams({ categoryId: e.target.value || undefined, page: "1" })
          }
          options={[
            { value: "", label: "Tümü" },
            ...(categories?.map((c) => ({ value: c.id, label: c.name })) ?? []),
          ]}
          className="min-w-[160px]"
        />

        <Select
          label="Sırala"
          value={params.sortBy ?? ""}
          onChange={(e) =>
            updateParams({
              sortBy: (e.target.value || undefined) as ProductSortBy | undefined,
              page: "1",
            })
          }
          options={[
            { value: "", label: "Varsayılan" },
            { value: "price_asc", label: "Fiyat (Artan)" },
            { value: "price_desc", label: "Fiyat (Azalan)" },
            { value: "rating_desc", label: "Puan" },
            { value: "newest", label: "En Yeni" },
          ]}
          className="min-w-[160px]"
        />
        </div>
        )}
      </div>

      {!isLoading && displayProducts.length === 0 ? (
        <EmptyState
          title={isPetDeal ? "Kampanya ürünü bulunamadı" : "Ürün bulunamadı"}
          description={
            isPetDeal
              ? "Kedi ve köpek ürünleri henüz yüklenmemiş olabilir."
              : "Farklı filtreler deneyin."
          }
        />
      ) : (
        <>
          <ProductGrid
            products={displayProducts}
            loading={isLoading}
            onAddToCart={handleAddToCart}
            addingId={addingId}
            getDiscountPercent={getDiscountPercent}
          />
          {!isPetDeal && data && (
            <Pagination
              pageIndex={data.pageIndex}
              totalPages={data.totalPages}
              onPageChange={(page) => updateParams({ page: String(page) })}
            />
          )}
        </>
      )}
    </div>
  );
}

export default function ProductsPage() {
  return (
    <Suspense fallback={<ProductGrid products={[]} loading />}>
      <ProductsContent />
    </Suspense>
  );
}
