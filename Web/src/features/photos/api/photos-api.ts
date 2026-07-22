import { parseApiResponse } from "@/lib/api/envelope";
import type { PhotoUploadResult } from "@/types/api";

export const photosApi = {
  upload: async (file: File): Promise<PhotoUploadResult> => {
    const form = new FormData();
    form.append("file", file);

    const response = await fetch("/api/bff/photos", {
      method: "POST",
      body: form,
      credentials: "same-origin",
    });

    return parseApiResponse<PhotoUploadResult>(response);
  },
};
