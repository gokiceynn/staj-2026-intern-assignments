"use client";

import Image from "next/image";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  useSellerOrder,
  useSellerCarriers,
  usePrepareSellerOrder,
  useShipSellerOrder,
  useDeliverSellerOrder,
} from "@/features/seller/queries/use-seller";
import { useOrderStatusLabel } from "@/features/metadata/queries/use-metadata";
import { Price } from "@/components/ui/Price";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

const shipSchema = z.object({
  carrierId: z.string().min(1, "Kargo firması seçin"),
  trackingNumber: z.string().min(1, "Takip numarası gerekli"),
});

type ShipInput = z.infer<typeof shipSchema>;

export default function SellerOrderDetailPage() {
  const params = useParams<{ id: string }>();
  const { data: order, isLoading, error, refetch } = useSellerOrder(params.id);
  const { data: carriers } = useSellerCarriers();
  const prepareOrder = usePrepareSellerOrder();
  const shipOrder = useShipSellerOrder();
  const deliverOrder = useDeliverSellerOrder();
  const { showToast } = useToast();
  const statusLabel = useOrderStatusLabel(order?.status ?? "");

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<ShipInput>({ resolver: zodResolver(shipSchema) });

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !order) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Sipariş bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  const handlePrepare = async () => {
    try {
      await prepareOrder.mutateAsync(params.id);
      showToast("Sipariş hazırlanıyor olarak işaretlendi", "success");
      refetch();
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "İşlem başarısız",
        "error",
      );
    }
  };

  const onShip = async (data: ShipInput) => {
    try {
      await shipOrder.mutateAsync({ packageId: params.id, input: data });
      showToast("Sipariş kargoya verildi", "success");
      refetch();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof ShipInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Kargo işlemi başarısız",
          "error",
        );
      }
    }
  };

  const handleDeliver = async () => {
    try {
      await deliverOrder.mutateAsync(params.id);
      showToast("Sipariş teslim edildi", "success");
      refetch();
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "İşlem başarısız",
        "error",
      );
    }
  };

  const status = order.status.toLowerCase();

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Link href="/seller/orders" className="text-sm text-brand-600 hover:underline">
        ← Siparişler
      </Link>

      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold">{order.orderNumber}</h2>
          <p className="text-sm text-text-muted">{formatDate(order.createdAt)}</p>
        </div>
        <Badge variant="success">{statusLabel}</Badge>
      </div>

      <div className="rounded-lg border border-border bg-surface p-4">
        <h3 className="mb-2 font-semibold">Müşteri</h3>
        <p className="text-sm">{order.customer.fullName}</p>
        <p className="text-sm text-text-muted">{order.customer.phoneNumber}</p>
      </div>

      {order.shipment?.trackingNumber && (
        <div className="rounded-lg border border-border bg-surface p-4">
          <h3 className="mb-2 font-semibold">Kargo</h3>
          <p className="text-sm">Takip No: {order.shipment.trackingNumber}</p>
          {order.shipment.trackingUrl && (
            <a
              href={order.shipment.trackingUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm text-brand-600 hover:underline"
            >
              Kargo takibi
            </a>
          )}
        </div>
      )}

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

      <div className="space-y-4 rounded-lg border border-border bg-surface p-4">
        <h3 className="font-semibold">İşlemler</h3>

        {status === "paid" && (
          <Button onClick={handlePrepare} loading={prepareOrder.isPending}>
            Hazırlamaya Başla
          </Button>
        )}

        {status === "preparing" && (
          <form onSubmit={handleSubmit(onShip)} className="space-y-4">
            <Select
              label="Kargo Firması"
              options={[
                { value: "", label: "Seçin" },
                ...(carriers?.map((c) => ({ value: c.id, label: c.name })) ?? []),
              ]}
              error={errors.carrierId?.message}
              {...register("carrierId")}
            />
            <Input
              label="Takip Numarası"
              error={errors.trackingNumber?.message}
              {...register("trackingNumber")}
            />
            <Button type="submit" loading={shipOrder.isPending}>
              Kargoya Ver
            </Button>
          </form>
        )}

        {status === "shipped" && (
          <Button onClick={handleDeliver} loading={deliverOrder.isPending}>
            Teslim Edildi Olarak İşaretle
          </Button>
        )}
      </div>
    </div>
  );
}
