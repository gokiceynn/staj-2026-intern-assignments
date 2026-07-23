"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { addressSchema, type AddressInput } from "@/features/addresses/schemas/address";
import {
  useAddresses,
  useCreateAddress,
  useUpdateAddress,
  useDeleteAddress,
} from "@/features/addresses/queries/use-addresses";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
import { ConfirmDialog } from "@/components/ui/ConfirmDialog";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";
import type { Address } from "@/types/api";
import Link from "next/link";

export default function AddressesPage() {
  const { data: addresses, isLoading, error, refetch } = useAddresses();
  const createAddress = useCreateAddress();
  const updateAddress = useUpdateAddress();
  const deleteAddress = useDeleteAddress();
  const { showToast } = useToast();

  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Address | null>(null);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors },
  } = useForm<AddressInput>({ resolver: zodResolver(addressSchema) });

  const openCreate = () => {
    setEditing(null);
    reset({
      title: "",
      addressLine: "",
      city: "",
      district: "",
      zipCode: "",
      phoneNumber: "",
    });
    setModalOpen(true);
  };

  const openEdit = (address: Address) => {
    setEditing(address);
    reset(address);
    setModalOpen(true);
  };

  const onSubmit = async (data: AddressInput) => {
    try {
      if (editing) {
        await updateAddress.mutateAsync({ id: editing.id, input: data });
        showToast("Adres güncellendi", "success");
      } else {
        await createAddress.mutateAsync(data);
        showToast("Adres eklendi", "success");
      }
      setModalOpen(false);
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof AddressInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "İşlem başarısız",
          "error",
        );
      }
    }
  };

  const handleDelete = async () => {
    if (!deletingId) return;
    try {
      await deleteAddress.mutateAsync(deletingId);
      showToast("Adres silindi", "success");
      setDeletingId(null);
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Silinemedi",
        "error",
      );
    }
  };

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Adresler yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Adreslerim</h1>
        <div className="flex gap-2">
          <Link href="/profile" className="text-sm text-brand-600 hover:underline">
            ← Profil
          </Link>
          <Button size="sm" onClick={openCreate}>
            Yeni Adres
          </Button>
        </div>
      </div>

      {!addresses || addresses.length === 0 ? (
        <EmptyState
          title="Kayıtlı adres yok"
          description="Teslimat için bir adres ekleyin."
          action={<Button onClick={openCreate}>Adres Ekle</Button>}
        />
      ) : (
        <div className="space-y-4">
          {addresses.map((address) => (
            <div
              key={address.id}
              className="rounded-lg border border-border bg-surface p-4"
            >
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-semibold">{address.title}</h3>
                  <p className="mt-1 text-sm text-text-muted">
                    {address.addressLine}
                  </p>
                  <p className="text-sm text-text-muted">
                    {address.district}, {address.city} {address.zipCode}
                  </p>
                  <p className="text-sm text-text-muted">{address.phoneNumber}</p>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" onClick={() => openEdit(address)}>
                    Düzenle
                  </Button>
                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => setDeletingId(address.id)}
                  >
                    Sil
                  </Button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? "Adresi Düzenle" : "Yeni Adres"}
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <Input label="Başlık" error={errors.title?.message} {...register("title")} />
          <Input
            label="Adres"
            error={errors.addressLine?.message}
            {...register("addressLine")}
          />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Şehir" error={errors.city?.message} {...register("city")} />
            <Input
              label="İlçe"
              error={errors.district?.message}
              {...register("district")}
            />
          </div>
          <Input
            label="Posta Kodu"
            error={errors.zipCode?.message}
            {...register("zipCode")}
          />
          <Input
            label="Telefon"
            error={errors.phoneNumber?.message}
            {...register("phoneNumber")}
          />
          <Button
            type="submit"
            className="w-full"
            loading={createAddress.isPending || updateAddress.isPending}
          >
            Kaydet
          </Button>
        </form>
      </Modal>

      <ConfirmDialog
        open={Boolean(deletingId)}
        onClose={() => setDeletingId(null)}
        onConfirm={handleDelete}
        title="Adresi Sil"
        message="Bu adresi silmek istediğinize emin misiniz?"
        confirmLabel="Sil"
        loading={deleteAddress.isPending}
      />
    </div>
  );
}
