"use client";

import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  useSellerProfile,
  useUpdateSellerProfile,
} from "@/features/seller/queries/use-seller";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Skeleton } from "@/components/ui/Skeleton";
import { ErrorState } from "@/components/ui/ErrorState";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

const profileSchema = z.object({
  storeName: z.string().min(1, "Mağaza adı gerekli"),
  description: z.string(),
  taxOffice: z.string().min(1, "Vergi dairesi gerekli"),
});

type ProfileInput = z.infer<typeof profileSchema>;

export default function SellerProfilePage() {
  const { data: profile, isLoading, error, refetch } = useSellerProfile();
  const updateProfile = useUpdateSellerProfile();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors },
  } = useForm<ProfileInput>({ resolver: zodResolver(profileSchema) });

  useEffect(() => {
    if (profile) {
      reset({
        storeName: profile.storeName,
        description: profile.description,
        taxOffice: profile.taxOffice,
      });
    }
  }, [profile, reset]);

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !profile) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Profil yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  const onSubmit = async (data: ProfileInput) => {
    try {
      await updateProfile.mutateAsync(data);
      showToast("Mağaza profili güncellendi", "success");
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof ProfileInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Güncelleme başarısız",
          "error",
        );
      }
    }
  };

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <h2 className="text-xl font-semibold">Mağaza Profili</h2>
      <p className="text-sm text-text-muted">Vergi No: {profile.taxNumber}</p>

      <form
        onSubmit={handleSubmit(onSubmit)}
        className="space-y-4 rounded-lg border border-border bg-surface p-6"
      >
        <Input
          label="Mağaza Adı"
          error={errors.storeName?.message}
          {...register("storeName")}
        />
        <div className="flex flex-col gap-1">
          <label htmlFor="description" className="text-sm font-medium text-text">
            Açıklama
          </label>
          <textarea
            id="description"
            rows={4}
            className="rounded-md border border-border bg-surface px-3 py-2 text-sm text-text focus:border-brand-500 focus:outline-none"
            {...register("description")}
          />
        </div>
        <Input
          label="Vergi Dairesi"
          error={errors.taxOffice?.message}
          {...register("taxOffice")}
        />
        <Button type="submit" loading={updateProfile.isPending}>
          Kaydet
        </Button>
      </form>
    </div>
  );
}
