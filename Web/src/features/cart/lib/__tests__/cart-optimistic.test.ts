import { describe, it, expect } from "vitest";
import type { Cart, CartItem } from "@/types/api";
import {
  optimisticAddItem,
  optimisticClearCart,
  optimisticRemoveItem,
  optimisticUpdateItem,
  type CartProductSnapshot,
} from "@/features/cart/lib/cart-optimistic";

describe("cart optimistic updates", () => {
  const sampleItem: CartItem = {
    productId: "p1",
    productTitle: "Test Ürün",
    price: 100,
    quantity: 2,
    totalPrice: 200,
    photoId: "photo1",
    photoUrl: "/photos/photo1",
    stock: 10,
  };

  const cart: Cart = {
    items: [sampleItem],
    subtotal: 200,
    totalAmount: 200,
    currency: "TRY",
  };

  it("adds quantity for existing item", () => {
    const next = optimisticAddItem(cart, "p1", 1);
    expect(next.items[0]?.quantity).toBe(3);
    expect(next.totalAmount).toBe(300);
  });

  it("adds new item with product snapshot", () => {
    const product: CartProductSnapshot = {
      productTitle: "Yeni Ürün",
      price: 50,
      photoUrl: "/photos/p2",
      photoId: "photo2",
    };
    const next = optimisticAddItem(cart, "p2", 2, product);
    expect(next.items).toHaveLength(2);
    expect(next.items[1]?.quantity).toBe(2);
    expect(next.totalAmount).toBe(300);
  });

  it("updates item quantity", () => {
    const next = optimisticUpdateItem(cart, "p1", 5);
    expect(next.items[0]?.quantity).toBe(5);
    expect(next.totalAmount).toBe(500);
  });

  it("removes item", () => {
    const next = optimisticRemoveItem(cart, "p1");
    expect(next.items).toHaveLength(0);
    expect(next.totalAmount).toBe(0);
  });

  it("clears cart", () => {
    const next = optimisticClearCart();
    expect(next.items).toHaveLength(0);
    expect(next.totalAmount).toBe(0);
  });
});
