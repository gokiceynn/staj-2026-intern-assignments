import { apiClient } from "@/lib/api/client";
import { withPhotoUrls } from "@/lib/utils/photo-url";
import type { Cart, CartItem } from "@/types/api";
import type {
  AddToCartInput,
  UpdateCartItemInput,
} from "@/features/cart/schemas/cart";

type ApiCartProduct = {
  id: string;
  title: string;
  price: number;
  stock: number;
  photoId: string | null;
  sellerId: string;
  sellerName: string;
};

type ApiCartItem = {
  productId: string;
  quantity: number;
  lineTotal: number;
  product: ApiCartProduct;
};

type ApiCart = {
  id: string;
  items: ApiCartItem[];
  subtotal: number;
  totalQuantity: number;
};

function normalizeCart(raw: ApiCart): Cart {
  const items: CartItem[] = raw.items.map((item) => ({
    productId: item.productId,
    productTitle: item.product.title,
    sellerId: item.product.sellerId,
    sellerName: item.product.sellerName,
    price: item.product.price,
    quantity: item.quantity,
    totalPrice: item.lineTotal,
    stock: item.product.stock,
    photoId: item.product.photoId ?? "",
    photoUrl: "",
  }));

  return {
    items: withPhotoUrls(items),
    subtotal: raw.subtotal,
    totalAmount: raw.subtotal,
    currency: "TRY",
  };
}

export const cartApi = {
  get: async () => normalizeCart(await apiClient<ApiCart>("cart")),

  addItem: async (input: AddToCartInput) =>
    normalizeCart(
      await apiClient<ApiCart>("cart/items", { method: "POST", body: input }),
    ),

  updateItem: async (productId: string, input: UpdateCartItemInput) =>
    normalizeCart(
      await apiClient<ApiCart>(`cart/items/${productId}`, {
        method: "PUT",
        body: input,
      }),
    ),

  removeItem: async (productId: string) =>
    normalizeCart(
      await apiClient<ApiCart>(`cart/items/${productId}`, { method: "DELETE" }),
    ),

  clear: () => apiClient<null>("cart", { method: "DELETE" }),
};
