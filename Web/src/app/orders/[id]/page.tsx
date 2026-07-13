"use client";

import Image from "next/image";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useOrder, useCancelOrder } from "@/features/orders/queries/use-orders";
import { cancelOrderSchema, type CancelOrderInput } from "@/features/orders/schemas/order";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Modal } from "@/components/ui/Modal";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

export default function OrderDetailPage() {
  const params = useParams<{ id: string }>();
  const { data: order, isLoading, error, refetch } = useOrder(params.id);
  const cancelOrder = useCancelOrder();
  const { showToast } = useToast();
  const [cancelOpen, setCancelOpen] = useState(false);

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<CancelOrderInput>({ resolver: zodResolver(cancelOrderSchema) });

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !order) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Sipariş bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  const onCancel = async (data: CancelOrderInput) => {
    try {
      await cancelOrder.mutateAsync({ id: params.id, input: data });
      showToast("Sipariş iptal edildi", "success");
      setCancelOpen(false);
      refetch();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof CancelOrderInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "İptal başarısız",
          "error",
        );
      }
    }
  };

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Link href="/orders" className="text-sm text-brand-600 hover:underline">
            ← Siparişler
          </Link>
          <h1 className="mt-2 text-2xl font-bold">{order.orderNumber}</h1>
          <p className="text-sm text-text-muted">{formatDate(order.createdAt)}</p>
        </div>
        <Badge variant="success">{order.status}</Badge>
      </div>

      <div className="rounded-lg border border-border bg-surface p-4">
        <h2 className="mb-2 font-semibold">Teslimat Adresi</h2>
        <p className="text-sm text-text-muted">
          {order.shippingAddress.addressLine}
        </p>
        <p className="text-sm text-text-muted">
          {order.shippingAddress.district}, {order.shippingAddress.city}
        </p>
      </div>

      <div className="space-y-4">
        <h2 className="font-semibold">Ürünler</h2>
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

      {order.status !== "Cancelled" && (
        <Button variant="danger" onClick={() => setCancelOpen(true)}>
          Siparişi İptal Et
        </Button>
      )}

      <Modal open={cancelOpen} onClose={() => setCancelOpen(false)} title="Siparişi İptal Et">
        <form onSubmit={handleSubmit(onCancel)} className="space-y-4">
          <Input
            label="İptal Nedeni"
            error={errors.cancelReason?.message}
            {...register("cancelReason")}
          />
          <Button type="submit" variant="danger" loading={cancelOrder.isPending}>
            İptal Et
          </Button>
        </form>
      </Modal>
    </div>
  );
}
