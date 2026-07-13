"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useOrders } from "@/features/orders/queries/use-orders";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

function OrdersContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");

  const { data, isLoading, error, refetch } = useOrders({ page, size: 10 });

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
    return (
      <EmptyState
        title="Henüz sipariş yok"
        description="İlk siparişinizi vermek için alışverişe başlayın."
      />
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Siparişlerim</h1>

      <div className="space-y-4">
        {data.items.map((order) => (
          <Link
            key={order.orderId}
            href={`/orders/${order.orderId}`}
            className="block rounded-lg border border-border bg-surface p-4 transition-shadow hover:shadow-md"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="font-semibold">{order.orderNumber}</p>
                <p className="text-sm text-text-muted">
                  {formatDate(order.createdAt)} · {order.itemCount} ürün
                </p>
              </div>
              <div className="text-right">
                <Price amount={order.totalAmount} />
                <Badge className="mt-1">{order.status}</Badge>
              </div>
            </div>
          </Link>
        ))}
      </div>

      <Pagination
        pageIndex={data.pageIndex}
        totalPages={data.totalPages}
        onPageChange={(p) => router.push(`/orders?page=${p}`)}
      />
    </div>
  );
}

export default function OrdersPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <OrdersContent />
    </Suspense>
  );
}
