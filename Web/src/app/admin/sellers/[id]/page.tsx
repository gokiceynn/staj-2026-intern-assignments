"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useAdminSeller } from "@/features/admin/queries/use-admin";
import { Badge } from "@/components/ui/Badge";
import { Rating } from "@/components/ui/Rating";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

export default function AdminSellerDetailPage() {
  const params = useParams<{ id: string }>();
  const { data: seller, isLoading, error, refetch } = useAdminSeller(params.id);

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !seller) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Satıcı bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <Link href="/admin/sellers" className="text-sm text-brand-600 hover:underline">
        ← Satıcılar
      </Link>
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">{seller.storeName}</h2>
        <Badge variant={seller.isActive ? "success" : "default"}>
          {seller.isActive ? "Aktif" : "Pasif"}
        </Badge>
      </div>

      <div className="space-y-3 rounded-lg border border-border bg-surface p-6 text-sm">
        <div className="flex justify-between">
          <span className="text-text-muted">Açıklama</span>
          <span className="max-w-xs text-right">{seller.description || "—"}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Vergi No</span>
          <span>{seller.taxNumber}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Vergi Dairesi</span>
          <span>{seller.taxOffice}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Puan</span>
          <Rating value={seller.rating} />
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Ürün Sayısı</span>
          <span>{seller.productCount}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Kayıt Tarihi</span>
          <span>{formatDate(seller.createdAt)}</span>
        </div>
      </div>
    </div>
  );
}
