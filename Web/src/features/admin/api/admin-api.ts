import { apiClient } from "@/lib/api/client";
import { normalizePaginated } from "@/lib/api/pagination";
import type {
  AdminDashboard,
  AdminOrderListItem,
  AdminSellerDetail,
  AdminSellerListItem,
  AdminUserDetail,
  AdminUserListItem,
  OrderDetail,
  Paginated,
  ShippingCarrier,
} from "@/types/api";

export type ShippingCarrierWriteInput = {
  name: string;
  code: string;
  logoId?: string | null;
  flatFee: number;
  estimatedDeliveryDays: number;
  trackingUrlTemplate: string;
  isActive: boolean;
};

export const adminApi = {
  getDashboard: (params?: { from?: string; to?: string }) =>
    apiClient<AdminDashboard>("admin/dashboard", { params }),

  listUsers: async (params?: {
    page?: number;
    size?: number;
    q?: string;
    role?: string;
    isActive?: boolean;
  }): Promise<Paginated<AdminUserListItem>> =>
    normalizePaginated<AdminUserListItem>(
      await apiClient<unknown>("admin/users", { params }),
    ),

  getUser: (id: string) => apiClient<AdminUserDetail>(`admin/users/${id}`),

  listSellers: async (params?: {
    page?: number;
    size?: number;
    q?: string;
    isActive?: boolean;
  }): Promise<Paginated<AdminSellerListItem>> =>
    normalizePaginated<AdminSellerListItem>(
      await apiClient<unknown>("admin/sellers", { params }),
    ),

  getSeller: (id: string) =>
    apiClient<AdminSellerDetail>(`admin/sellers/${id}`),

  listOrders: async (params?: {
    page?: number;
    size?: number;
    status?: string;
    from?: string;
    to?: string;
  }): Promise<Paginated<AdminOrderListItem>> =>
    normalizePaginated<AdminOrderListItem>(
      await apiClient<unknown>("admin/orders", { params }),
    ),

  getOrder: (id: string) =>
    apiClient<{ order: OrderDetail; customerEmail: string }>(
      `admin/orders/${id}`,
    ),

  listCarriers: () =>
    apiClient<ShippingCarrier[]>("admin/shipping-carriers"),

  getCarrier: (id: string) =>
    apiClient<ShippingCarrier>(`admin/shipping-carriers/${id}`),

  createCarrier: (input: ShippingCarrierWriteInput) =>
    apiClient<ShippingCarrier>("admin/shipping-carriers", {
      method: "POST",
      body: input,
    }),

  updateCarrier: (id: string, input: ShippingCarrierWriteInput) =>
    apiClient<ShippingCarrier>(`admin/shipping-carriers/${id}`, {
      method: "PUT",
      body: input,
    }),

  deleteCarrier: (id: string) =>
    apiClient<null>(`admin/shipping-carriers/${id}`, { method: "DELETE" }),
};
