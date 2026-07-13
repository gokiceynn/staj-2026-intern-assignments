import { apiClient } from "@/lib/api/client";
import type {
  Paginated,
  ProductDetail,
  ProductListItem,
  ProductQueryParams,
} from "@/types/api";
import { buildProductQueryParams } from "@/lib/utils/query-params";

export const productsApi = {
  list: (params: ProductQueryParams = {}) =>
    apiClient<Paginated<ProductListItem>>("products", {
      params: buildProductQueryParams(params),
    }),

  getById: (id: string) => apiClient<ProductDetail>(`products/${id}`),
};
