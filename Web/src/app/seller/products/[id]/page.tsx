"use client";

import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  useSellerProduct,
  useUpdateSellerProduct,
} from "@/features/seller/queries/use-seller";
import { useRootCategories } from "@/features/categories/queries/use-categories";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { Button } from "@/components/ui/Button";
import { Skeleton } from "@/components/ui/Skeleton";
import { ErrorState } from "@/components/ui/ErrorState";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

const productSchema = z.object({
  title: z.string().min(1, "Başlık gerekli"),
  description: z.string().min(1, "Açıklama gerekli"),
  price: z.coerce.number().min(0.01, "Geçerli fiyat girin"),
  stock: z.coerce.number().int().min(0, "Stok 0 veya daha büyük olmalı"),
  categoryId: z.string().min(1, "Kategori seçin"),
  isActive: z.boolean(),
  featuresJson: z.string().optional(),
});

type ProductFormInput = z.infer<typeof productSchema>;

export default function EditProductPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data: product, isLoading, error, refetch } = useSellerProduct(params.id);
  const updateProduct = useUpdateSellerProduct();
  const { data: categories, isLoading: categoriesLoading } = useRootCategories();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors },
  } = useForm<ProductFormInput>({ resolver: zodResolver(productSchema) });

  useEffect(() => {
    if (product) {
      reset({
        title: product.title,
        description: product.description,
        price: product.price,
        stock: product.stock,
        categoryId: product.categoryId,
        isActive: product.isActive,
        featuresJson: Object.keys(product.features).length
          ? JSON.stringify(product.features, null, 2)
          : "",
      });
    }
  }, [product, reset]);

  const onSubmit = async (data: ProductFormInput) => {
    let features: Record<string, string> = {};
    if (data.featuresJson?.trim()) {
      try {
        features = JSON.parse(data.featuresJson) as Record<string, string>;
      } catch {
        setError("featuresJson", { message: "Geçerli JSON girin" });
        return;
      }
    }

    try {
      await updateProduct.mutateAsync({
        id: params.id,
        input: {
          title: data.title,
          description: data.description,
          price: data.price,
          stock: data.stock,
          categoryId: data.categoryId,
          photoIds: product?.photoIds ?? [],
          features,
          isActive: data.isActive,
        },
      });
      showToast("Ürün güncellendi", "success");
      router.push("/seller/products");
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          if (field in data) {
            setError(field as keyof ProductFormInput, { message: messages[0] });
          }
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Güncelleme başarısız",
          "error",
        );
      }
    }
  };

  if (isLoading || categoriesLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !product) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Ürün bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <Link href="/seller/products" className="text-sm text-brand-600 hover:underline">
        ← Ürünler
      </Link>
      <h2 className="text-xl font-semibold">Ürün Düzenle</h2>

      <form
        onSubmit={handleSubmit(onSubmit)}
        className="space-y-4 rounded-lg border border-border bg-surface p-6"
      >
        <Input label="Başlık" error={errors.title?.message} {...register("title")} />
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
          {errors.description && (
            <p className="text-sm text-danger">{errors.description.message}</p>
          )}
        </div>
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Fiyat (₺)"
            type="number"
            step="0.01"
            error={errors.price?.message}
            {...register("price")}
          />
          <Input
            label="Stok"
            type="number"
            error={errors.stock?.message}
            {...register("stock")}
          />
        </div>
        <Select
          label="Kategori"
          options={[
            { value: "", label: "Seçin" },
            ...(categories?.map((c) => ({ value: c.id, label: c.name })) ?? []),
          ]}
          error={errors.categoryId?.message}
          {...register("categoryId")}
        />
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" {...register("isActive")} />
          Aktif
        </label>
        <div className="flex flex-col gap-1">
          <label htmlFor="featuresJson" className="text-sm font-medium text-text">
            Özellikler (JSON, isteğe bağlı)
          </label>
          <textarea
            id="featuresJson"
            rows={3}
            placeholder='{"Renk": "Siyah", "Beden": "M"}'
            className="rounded-md border border-border bg-surface px-3 py-2 font-mono text-sm text-text focus:border-brand-500 focus:outline-none"
            {...register("featuresJson")}
          />
          {errors.featuresJson && (
            <p className="text-sm text-danger">{errors.featuresJson.message}</p>
          )}
        </div>
        <Button type="submit" loading={updateProduct.isPending}>
          Kaydet
        </Button>
      </form>
    </div>
  );
}
