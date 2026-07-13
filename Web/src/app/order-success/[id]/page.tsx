"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useOrder } from "@/features/orders/queries/use-orders";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { formatDate } from "@/lib/utils/format";
import { Skeleton } from "@/components/ui/Skeleton";
import { ErrorState } from "@/components/ui/ErrorState";
import { ApiError } from "@/lib/api/envelope";

export default function OrderSuccessPage() {
  const params = useParams<{ id: string }>();
  const { data: order, isLoading, error, refetch } = useOrder(params.id);

  if (isLoading) {
    return <Skeleton className="h-64 w-full" />;
  }

  if (error || !order) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Sipariş bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="mx-auto max-w-lg space-y-6 text-center">
      <div className="text-5xl">✓</div>
      <h1 className="text-2xl font-bold text-success">Siparişiniz Alındı!</h1>
      <p className="text-text-muted">
        Sipariş numaranız: <strong>{order.orderNumber}</strong>
      </p>

      <div className="rounded-lg border border-border bg-surface p-6 text-left">
        <div className="flex items-center justify-between">
          <span className="text-sm text-text-muted">Durum</span>
          <Badge variant="success">{order.status}</Badge>
        </div>
        <div className="mt-2 flex items-center justify-between">
          <span className="text-sm text-text-muted">Tarih</span>
          <span className="text-sm">{formatDate(order.createdAt)}</span>
        </div>
        <div className="mt-2 flex items-center justify-between">
          <span className="text-sm text-text-muted">Toplam</span>
          <Price amount={order.totalAmount} />
        </div>
      </div>

      <div className="flex justify-center gap-4">
        <Link
          href={`/orders/${order.orderId}`}
          className="inline-flex h-10 items-center justify-center rounded-md border border-border px-4 text-sm font-medium hover:bg-surface-muted"
        >
          Sipariş Detayı
        </Link>
        <Link
          href="/products"
          className="inline-flex h-10 items-center justify-center rounded-md bg-brand-600 px-4 text-sm font-medium text-white hover:bg-brand-700"
        >
          Alışverişe Devam
        </Link>
      </div>
    </div>
  );
}
