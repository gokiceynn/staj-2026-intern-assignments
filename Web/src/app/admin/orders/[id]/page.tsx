"use client";

import Image from "next/image";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useAdminOrder } from "@/features/admin/queries/use-admin";
import { useOrderStatusLabel } from "@/features/metadata/queries/use-metadata";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

export default function AdminOrderDetailPage() {
  const params = useParams<{ id: string }>();
  const { data, isLoading, error, refetch } = useAdminOrder(params.id);
  const statusLabel = useOrderStatusLabel(data?.order.status ?? "");

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !data) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Sipariş bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  const { order, customerEmail } = data;

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Link href="/admin/orders" className="text-sm text-brand-600 hover:underline">
        ← Siparişler
      </Link>

      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold">{order.orderNumber}</h2>
          <p className="text-sm text-text-muted">{formatDate(order.createdAt)}</p>
          <p className="text-sm text-text-muted">{customerEmail}</p>
        </div>
        <Badge variant="success">{statusLabel}</Badge>
      </div>

      <div className="rounded-lg border border-border bg-surface p-4">
        <h3 className="mb-2 font-semibold">Teslimat Adresi</h3>
        <p className="text-sm text-text-muted">{order.shippingAddress.addressLine}</p>
        <p className="text-sm text-text-muted">
          {order.shippingAddress.district}, {order.shippingAddress.city}
        </p>
      </div>

      <div className="space-y-4">
        <h3 className="font-semibold">Ürünler</h3>
        {order.items.map((item) => (
          <div
            key={item.productId}
            className="flex gap-4 rounded-lg border border-border bg-surface p-4"
          >
            <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-md">
              <Image
                src={item.photoUrl}
                alt={item.productTitle}
                fill
                className="object-cover"
                sizes="64px"
              />
            </div>
            <div className="flex-1">
              <p className="font-medium">{item.productTitle}</p>
              <p className="text-sm text-text-muted">x{item.quantity}</p>
            </div>
            <Price amount={item.price * item.quantity} />
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between rounded-lg border border-border bg-surface p-4">
        <span className="text-lg font-semibold">Toplam</span>
        <Price amount={order.totalAmount} size="lg" />
      </div>
    </div>
  );
}
