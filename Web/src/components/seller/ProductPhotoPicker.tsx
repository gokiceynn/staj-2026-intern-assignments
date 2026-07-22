"use client";

import Image from "next/image";
import { useState } from "react";
import { photosApi } from "@/features/photos/api/photos-api";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";
import { photoUrlFromId } from "@/lib/utils/photo-url";

type ProductPhotoPickerProps = {
  photoIds: string[];
  onChange: (photoIds: string[]) => void;
  max?: number;
};

export function ProductPhotoPicker({
  photoIds,
  onChange,
  max = 10,
}: ProductPhotoPickerProps) {
  const { showToast } = useToast();
  const [uploading, setUploading] = useState(false);

  const handleFile = async (file: File | null) => {
    if (!file) return;
    if (photoIds.length >= max) {
      showToast(`En fazla ${max} fotoğraf ekleyebilirsiniz`, "error");
      return;
    }

    setUploading(true);
    try {
      const result = await photosApi.upload(file);
      onChange([...photoIds, result.photoId]);
      showToast("Fotoğraf yüklendi", "success");
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Fotoğraf yüklenemedi",
        "error",
      );
    } finally {
      setUploading(false);
    }
  };

  const removePhoto = (photoId: string) => {
    onChange(photoIds.filter((id) => id !== photoId));
  };

  return (
    <div className="flex flex-col gap-2">
      <label className="text-sm font-medium text-text">
        Ürün Fotoğrafı <span className="text-danger">*</span>
      </label>
      <p className="text-xs text-text-muted">
        En az 1 fotoğraf gerekli. JPG, PNG veya WebP (max 5 MB).
      </p>

      {photoIds.length > 0 && (
        <div className="flex flex-wrap gap-3">
          {photoIds.map((photoId) => (
            <div
              key={photoId}
              className="relative h-24 w-24 overflow-hidden rounded-lg border border-border bg-surface-muted"
            >
              <Image
                src={photoUrlFromId(photoId)}
                alt="Ürün fotoğrafı"
                fill
                className="object-cover"
                sizes="96px"
              />
              <button
                type="button"
                onClick={() => removePhoto(photoId)}
                className="absolute right-1 top-1 flex h-6 w-6 items-center justify-center rounded-full bg-black/60 text-xs text-white hover:bg-black/80"
                aria-label="Fotoğrafı kaldır"
              >
                ×
              </button>
            </div>
          ))}
        </div>
      )}

      <div>
        <input
          id="product-photo-upload"
          type="file"
          accept="image/jpeg,image/png,image/webp,image/gif"
          className="sr-only"
          disabled={uploading || photoIds.length >= max}
          onChange={(e) => {
            void handleFile(e.target.files?.[0] ?? null);
            e.target.value = "";
          }}
        />
        <Button
          type="button"
          variant="outline"
          size="sm"
          loading={uploading}
          disabled={photoIds.length >= max}
          onClick={() => document.getElementById("product-photo-upload")?.click()}
        >
          Fotoğraf Seç
        </Button>
      </div>
    </div>
  );
}
