"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useAdminSellers } from "@/features/admin/queries/use-admin";
import { Badge } from "@/components/ui/Badge";
import { Rating } from "@/components/ui/Rating";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { ApiError } from "@/lib/api/envelope";

function SellersContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const { data, isLoading, error, refetch } = useAdminSellers({ page, size: 10 });

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Satıcılar yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  if (!data || data.items.length === 0) {
    return <EmptyState title="Satıcı bulunamadı" />;
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">Satıcılar</h2>
      <div className="overflow-x-auto rounded-lg border border-border">
        <table className="w-full text-sm">
          <thead className="border-b border-border bg-surface-muted">
            <tr>
              <th className="px-4 py-3 text-left font-medium">Mağaza</th>
              <th className="px-4 py-3 text-left font-medium">E-posta</th>
              <th className="px-4 py-3 text-left font-medium">Puan</th>
              <th className="px-4 py-3 text-left font-medium">Ürün</th>
              <th className="px-4 py-3 text-left font-medium">Durum</th>
            </tr>
          </thead>
          <tbody>
            {data.items.map((seller) => (
              <tr key={seller.id} className="border-b border-border hover:bg-surface-muted">
                <td className="px-4 py-3">
                  <Link
                    href={`/admin/sellers/${seller.id}`}
                    className="font-medium text-brand-600 hover:underline"
                  >
                    {seller.storeName}
                  </Link>
                </td>
                <td className="px-4 py-3 text-text-muted">{seller.email}</td>
                <td className="px-4 py-3">
                  <Rating value={seller.rating} />
                </td>
                <td className="px-4 py-3">{seller.productCount}</td>
                <td className="px-4 py-3">
                  <Badge variant={seller.isActive ? "success" : "default"}>
                    {seller.isActive ? "Aktif" : "Pasif"}
                  </Badge>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Pagination
        pageIndex={data.pageIndex}
        totalPages={data.totalPages}
        onPageChange={(p) => router.push(`/admin/sellers?page=${p}`)}
      />
    </div>
  );
}

export default function AdminSellersPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <SellersContent />
    </Suspense>
  );
}
