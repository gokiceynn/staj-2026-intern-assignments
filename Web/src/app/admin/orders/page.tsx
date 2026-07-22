"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useAdminOrders } from "@/features/admin/queries/use-admin";
import { useOrderStatusLabel } from "@/features/metadata/queries/use-metadata";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

function OrderRow({
  order,
}: {
  order: {
    orderId: string;
    orderNumber: string;
    customerEmail: string;
    totalAmount: number;
    status: string;
    packageCount: number;
    createdAt: string;
  };
}) {
  const statusLabel = useOrderStatusLabel(order.status);

  return (
    <Link
      href={`/admin/orders/${order.orderId}`}
      className="block rounded-lg border border-border bg-surface p-4 transition-shadow hover:shadow-md"
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="font-semibold">{order.orderNumber}</p>
          <p className="text-sm text-text-muted">
            {order.customerEmail} · {order.packageCount} paket
          </p>
          <p className="text-sm text-text-muted">{formatDate(order.createdAt)}</p>
        </div>
        <div className="text-right">
          <Price amount={order.totalAmount} />
          <Badge className="mt-1">{statusLabel}</Badge>
        </div>
      </div>
    </Link>
  );
}

function OrdersContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const { data, isLoading, error, refetch } = useAdminOrders({ page, size: 10 });

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Siparişler yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  if (!data || data.items.length === 0) {
    return <EmptyState title="Sipariş bulunamadı" />;
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">Siparişler</h2>
      <div className="space-y-4">
        {data.items.map((order) => (
          <OrderRow key={order.orderId} order={order} />
        ))}
      </div>
      <Pagination
        pageIndex={data.pageIndex}
        totalPages={data.totalPages}
        onPageChange={(p) => router.push(`/admin/orders?page=${p}`)}
      />
    </div>
  );
}

export default function AdminOrdersPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <OrdersContent />
    </Suspense>
  );
}
