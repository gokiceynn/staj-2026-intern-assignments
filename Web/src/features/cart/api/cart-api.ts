import { apiClient } from "@/lib/api/client";
import type { Cart } from "@/types/api";
import type {
  AddToCartInput,
  UpdateCartItemInput,
} from "@/features/cart/schemas/cart";

export const cartApi = {
  get: () => apiClient<Cart>("cart"),

  addItem: (input: AddToCartInput) =>
    apiClient<Cart>("cart/items", { method: "POST", body: input }),

  updateItem: (productId: string, input: UpdateCartItemInput) =>
    apiClient<Cart>(`cart/items/${productId}`, {
      method: "PUT",
      body: input,
    }),

  removeItem: (productId: string) =>
    apiClient<Cart>(`cart/items/${productId}`, { method: "DELETE" }),

  clear: () => apiClient<null>("cart", { method: "DELETE" }),
};
