import { apiClient } from "@/lib/api/client";
import { normalizePaginated } from "@/lib/api/pagination";
import { withPhotoUrl, withPhotoUrls } from "@/lib/utils/photo-url";
import type {
  Paginated,
  ProductDetail,
  ProductListItem,
  ProductQueryParams,
} from "@/types/api";
import { buildProductQueryParams } from "@/lib/utils/query-params";

export const productsApi = {
  list: async (params: ProductQueryParams = {}): Promise<Paginated<ProductListItem>> => {
    const page = normalizePaginated<ProductListItem>(
      await apiClient<unknown>("products", {
        params: buildProductQueryParams(params),
      }),
    );
    return { ...page, items: withPhotoUrls(page.items) };
  },

  getById: async (id: string) =>
    withPhotoUrl(await apiClient<ProductDetail>(`products/${id}`)),
};
