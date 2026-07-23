"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  useAdminCarriers,
  useCreateAdminCarrier,
  useUpdateAdminCarrier,
  useDeleteAdminCarrier,
} from "@/features/admin/queries/use-admin";
import type { ShippingCarrier } from "@/types/api";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Price } from "@/components/ui/Price";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

const carrierSchema = z.object({
  name: z.string().min(1, "Ad gerekli"),
  code: z.string().min(1, "Kod gerekli"),
  flatFee: z.coerce.number().min(0, "Geçerli ücret girin"),
  estimatedDeliveryDays: z.coerce.number().int().min(1, "En az 1 gün"),
  trackingUrlTemplate: z.string().min(1, "Takip URL şablonu gerekli"),
  isActive: z.boolean(),
});

type CarrierInput = z.infer<typeof carrierSchema>;

export default function AdminCarriersPage() {
  const { data: carriers, isLoading, error, refetch } = useAdminCarriers();
  const createCarrier = useCreateAdminCarrier();
  const updateCarrier = useUpdateAdminCarrier();
  const deleteCarrier = useDeleteAdminCarrier();
  const { showToast } = useToast();
  const [editing, setEditing] = useState<ShippingCarrier | null>(null);

  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors },
  } = useForm<CarrierInput>({
    resolver: zodResolver(carrierSchema),
    defaultValues: { isActive: true, estimatedDeliveryDays: 3, flatFee: 0 },
  });

  const startEdit = (carrier: ShippingCarrier) => {
    setEditing(carrier);
    reset({
      name: carrier.name,
      code: carrier.code,
      flatFee: carrier.flatFee,
      estimatedDeliveryDays: carrier.estimatedDeliveryDays,
      trackingUrlTemplate: carrier.trackingUrlTemplate,
      isActive: carrier.isActive,
    });
  };

  const cancelEdit = () => {
    setEditing(null);
    reset({ isActive: true, estimatedDeliveryDays: 3, flatFee: 0, name: "", code: "", trackingUrlTemplate: "" });
  };

  const onSubmit = async (data: CarrierInput) => {
    try {
      if (editing) {
        await updateCarrier.mutateAsync({ id: editing.id, input: data });
        showToast("Kargo firması güncellendi", "success");
      } else {
        await createCarrier.mutateAsync(data);
        showToast("Kargo firması oluşturuldu", "success");
      }
      cancelEdit();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof CarrierInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "İşlem başarısız",
          "error",
        );
      }
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`"${name}" kargo firmasını silmek istediğinize emin misiniz?`)) return;

    try {
      await deleteCarrier.mutateAsync(id);
      showToast("Kargo firması silindi", "success");
      if (editing?.id === id) cancelEdit();
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Silme başarısız",
        "error",
      );
    }
  };

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Kargo firmaları yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">Kargo Firmaları</h2>

      <form
        onSubmit={handleSubmit(onSubmit)}
        className="space-y-4 rounded-lg border border-border bg-surface p-6"
      >
        <h3 className="font-semibold">
          {editing ? "Kargo Firması Düzenle" : "Yeni Kargo Firması"}
        </h3>
        <div className="grid gap-4 sm:grid-cols-2">
          <Input label="Ad" error={errors.name?.message} {...register("name")} />
          <Input label="Kod" error={errors.code?.message} {...register("code")} />
          <Input
            label="Sabit Ücret (₺)"
            type="number"
            step="0.01"
            error={errors.flatFee?.message}
            {...register("flatFee")}
          />
          <Input
            label="Tahmini Teslimat (gün)"
            type="number"
            error={errors.estimatedDeliveryDays?.message}
            {...register("estimatedDeliveryDays")}
          />
        </div>
        <Input
          label="Takip URL Şablonu"
          placeholder="https://kargo.com/takip/{trackingNumber}"
          error={errors.trackingUrlTemplate?.message}
          {...register("trackingUrlTemplate")}
        />
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" {...register("isActive")} />
          Aktif
        </label>
        <div className="flex gap-2">
          <Button
            type="submit"
            loading={createCarrier.isPending || updateCarrier.isPending}
          >
            {editing ? "Güncelle" : "Oluştur"}
          </Button>
          {editing && (
            <Button type="button" variant="outline" onClick={cancelEdit}>
              İptal
            </Button>
          )}
        </div>
      </form>

      {!carriers || carriers.length === 0 ? (
        <EmptyState title="Kargo firması yok" />
      ) : (
        <div className="overflow-x-auto rounded-lg border border-border">
          <table className="w-full text-sm">
            <thead className="border-b border-border bg-surface-muted">
              <tr>
                <th className="px-4 py-3 text-left font-medium">Ad</th>
                <th className="px-4 py-3 text-left font-medium">Kod</th>
                <th className="px-4 py-3 text-left font-medium">Ücret</th>
                <th className="px-4 py-3 text-left font-medium">Teslimat</th>
                <th className="px-4 py-3 text-left font-medium">Durum</th>
                <th className="px-4 py-3 text-right font-medium">İşlemler</th>
              </tr>
            </thead>
            <tbody>
              {carriers.map((carrier) => (
                <tr key={carrier.id} className="border-b border-border">
                  <td className="px-4 py-3 font-medium">{carrier.name}</td>
                  <td className="px-4 py-3 text-text-muted">{carrier.code}</td>
                  <td className="px-4 py-3">
                    <Price amount={carrier.flatFee} size="sm" />
                  </td>
                  <td className="px-4 py-3">{carrier.estimatedDeliveryDays} gün</td>
                  <td className="px-4 py-3">
                    <Badge variant={carrier.isActive ? "success" : "default"}>
                      {carrier.isActive ? "Aktif" : "Pasif"}
                    </Badge>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <div className="flex justify-end gap-2">
                      <Button variant="outline" size="sm" onClick={() => startEdit(carrier)}>
                        Düzenle
                      </Button>
                      <Button
                        variant="danger"
                        size="sm"
                        loading={deleteCarrier.isPending}
                        onClick={() => handleDelete(carrier.id, carrier.name)}
                      >
                        Sil
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
