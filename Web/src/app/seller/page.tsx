"use client";

import { useSellerDashboard } from "@/features/seller/queries/use-seller";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatCurrency } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

function StatCard({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-lg border border-border bg-surface p-4">
      <p className="text-sm text-text-muted">{label}</p>
      <p className="mt-1 text-2xl font-bold">{value}</p>
    </div>
  );
}

export default function SellerDashboardPage() {
  const { data, isLoading, error, refetch } = useSellerDashboard();

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (error || !data) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Dashboard yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">Dashboard</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <StatCard label="Toplam Ürün" value={data.productCount} />
        <StatCard label="Aktif Ürün" value={data.activeProductCount} />
        <StatCard label="Düşük Stok" value={data.lowStockProductCount} />
        <StatCard label="Toplam Sipariş" value={data.totalOrderCount} />
        <StatCard label="Ödendi" value={data.paidPackageCount} />
        <StatCard label="Hazırlanıyor" value={data.preparingPackageCount} />
        <StatCard label="Kargoda" value={data.shippedPackageCount} />
        <StatCard label="Teslim Edildi" value={data.deliveredPackageCount} />
        <StatCard label="İptal" value={data.cancelledPackageCount} />
        <StatCard
          label="Brüt Satış"
          value={formatCurrency(data.grossSalesAmount)}
        />
      </div>
    </div>
  );
}
