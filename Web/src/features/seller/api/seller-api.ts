import { apiClient } from "@/lib/api/client";
import { normalizePaginated } from "@/lib/api/pagination";
import type {
  Paginated,
  SellerDashboard,
  SellerPackageDetail,
  SellerPackageListItem,
  SellerProductDetail,
  SellerProfile,
  ShippingCarrier,
} from "@/types/api";
import type { SellerProductCard } from "@/types/api";

export type SellerProductWriteInput = {
  title: string;
  description: string;
  price: number;
  stock: number;
  categoryId: string;
  photoIds: string[];
  features: Record<string, string>;
  isActive: boolean;
};

export const sellerApi = {
  getProfile: () => apiClient<SellerProfile>("seller/profile"),

  updateProfile: (input: {
    storeName: string;
    description: string;
    logoId?: string | null;
    taxOffice: string;
  }) =>
    apiClient<SellerProfile>("seller/profile", { method: "PUT", body: input }),

  getDashboard: (params?: { from?: string; to?: string }) =>
    apiClient<SellerDashboard>("seller/dashboard", { params }),

  listProducts: async (params?: {
    page?: number;
    size?: number;
    q?: string;
    isActive?: boolean;
  }): Promise<Paginated<SellerProductCard>> =>
    normalizePaginated<SellerProductCard>(
      await apiClient<unknown>("seller/products", { params }),
    ),

  getProduct: (id: string) =>
    apiClient<SellerProductDetail>(`seller/products/${id}`),

  createProduct: (input: SellerProductWriteInput) =>
    apiClient<SellerProductDetail>("seller/products", {
      method: "POST",
      body: input,
    }),

  updateProduct: (id: string, input: SellerProductWriteInput) =>
    apiClient<SellerProductDetail>(`seller/products/${id}`, {
      method: "PUT",
      body: input,
    }),

  deleteProduct: (id: string) =>
    apiClient<null>(`seller/products/${id}`, { method: "DELETE" }),

  listCarriers: () =>
    apiClient<ShippingCarrier[]>("seller/shipping-carriers"),

  listOrders: async (params?: {
    page?: number;
    size?: number;
    status?: string;
    from?: string;
    to?: string;
  }): Promise<Paginated<SellerPackageListItem>> =>
    normalizePaginated<SellerPackageListItem>(
      await apiClient<unknown>("seller/orders", { params }),
    ),

  getOrder: (packageId: string) =>
    apiClient<SellerPackageDetail>(`seller/orders/${packageId}`),

  prepareOrder: (packageId: string) =>
    apiClient<null>(`seller/orders/${packageId}/prepare`, { method: "POST" }),

  shipOrder: (
    packageId: string,
    input: { carrierId: string; trackingNumber: string },
  ) =>
    apiClient<null>(`seller/orders/${packageId}/ship`, {
      method: "POST",
      body: input,
    }),

  deliverOrder: (packageId: string) =>
    apiClient<null>(`seller/orders/${packageId}/deliver`, { method: "POST" }),
};
