"use client";

import { useAdminDashboard } from "@/features/admin/queries/use-admin";
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

export default function AdminDashboardPage() {
  const { data, isLoading, error, refetch } = useAdminDashboard();

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
        <StatCard label="Toplam Kullanıcı" value={data.userCount} />
        <StatCard label="Müşteri" value={data.customerCount} />
        <StatCard label="Satıcı" value={data.sellerCount} />
        <StatCard label="Aktif Ürün" value={data.activeProductCount} />
        <StatCard label="Sipariş" value={data.orderCount} />
        <StatCard
          label="Brüt Satış"
          value={formatCurrency(data.grossSalesAmount)}
        />
      </div>
    </div>
  );
}
