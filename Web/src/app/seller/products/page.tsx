"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import {
  useSellerProducts,
  useDeleteSellerProduct,
} from "@/features/seller/queries/use-seller";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";

function ProductsContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const { data, isLoading, error, refetch } = useSellerProducts({ page, size: 10 });
  const deleteProduct = useDeleteSellerProduct();
  const { showToast } = useToast();

  const handleDelete = async (id: string, title: string) => {
    if (!confirm(`"${title}" ürününü silmek istediğinize emin misiniz?`)) return;

    try {
      await deleteProduct.mutateAsync(id);
      showToast("Ürün silindi", "success");
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Silme başarısız",
        "error",
      );
    }
  };

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Ürünler yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  if (!data || data.items.length === 0) {
    return (
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold">Ürünler</h2>
          <Link href="/seller/products/new">
            <Button>Yeni Ürün</Button>
          </Link>
        </div>
        <EmptyState title="Henüz ürün yok" description="İlk ürününüzü ekleyin." />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">Ürünler</h2>
        <Link href="/seller/products/new">
          <Button>Yeni Ürün</Button>
        </Link>
      </div>

      <div className="overflow-x-auto rounded-lg border border-border">
        <table className="w-full text-sm">
          <thead className="border-b border-border bg-surface-muted">
            <tr>
              <th className="px-4 py-3 text-left font-medium">Ürün</th>
              <th className="px-4 py-3 text-left font-medium">Kategori</th>
              <th className="px-4 py-3 text-left font-medium">Fiyat</th>
              <th className="px-4 py-3 text-left font-medium">Stok</th>
              <th className="px-4 py-3 text-left font-medium">Durum</th>
              <th className="px-4 py-3 text-right font-medium">İşlemler</th>
            </tr>
          </thead>
          <tbody>
            {data.items.map(({ product, isActive }) => (
              <tr key={product.id} className="border-b border-border">
                <td className="px-4 py-3 font-medium">{product.title}</td>
                <td className="px-4 py-3 text-text-muted">{product.category.name}</td>
                <td className="px-4 py-3">
                  <Price amount={product.price} size="sm" />
                </td>
                <td className="px-4 py-3">{product.stock}</td>
                <td className="px-4 py-3">
                  <Badge variant={isActive ? "success" : "default"}>
                    {isActive ? "Aktif" : "Pasif"}
                  </Badge>
                </td>
                <td className="px-4 py-3 text-right">
                  <div className="flex justify-end gap-2">
                    <Link href={`/seller/products/${product.id}`}>
                      <Button variant="outline" size="sm">
                        Düzenle
                      </Button>
                    </Link>
                    <Button
                      variant="danger"
                      size="sm"
                      loading={deleteProduct.isPending}
                      onClick={() => handleDelete(product.id, product.title)}
                    >
                      Sil
                    </Button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Pagination
        pageIndex={data.pageIndex}
        totalPages={data.totalPages}
        onPageChange={(p) => router.push(`/seller/products?page=${p}`)}
      />
    </div>
  );
}

export default function SellerProductsPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <ProductsContent />
    </Suspense>
  );
}
