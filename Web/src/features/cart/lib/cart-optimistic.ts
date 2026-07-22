import type { Cart, CartItem } from "@/types/api";

export type CartProductSnapshot = {
  productTitle: string;
  price: number;
  photoUrl: string;
  photoId?: string;
  stock?: number;
  sellerId?: string;
  sellerName?: string;
};

const EMPTY_CART: Cart = {
  items: [],
  subtotal: 0,
  totalAmount: 0,
  currency: "TRY",
};

function recalcCart(items: CartItem[]): Cart {
  const subtotal = items.reduce((sum, item) => sum + item.totalPrice, 0);
  return {
    items,
    subtotal,
    totalAmount: subtotal,
    currency: "TRY",
  };
}

export function optimisticAddItem(
  cart: Cart | undefined,
  productId: string,
  quantity: number,
  product?: CartProductSnapshot,
): Cart {
  const current = cart ?? EMPTY_CART;
  const existing = current.items.find((item) => item.productId === productId);

  if (existing) {
    const items = current.items.map((item) => {
      if (item.productId !== productId) return item;
      const nextQuantity = item.quantity + quantity;
      return {
        ...item,
        quantity: nextQuantity,
        totalPrice: item.price * nextQuantity,
      };
    });
    return recalcCart(items);
  }

  const snapshot: CartItem = product
    ? {
        productId,
        productTitle: product.productTitle,
        price: product.price,
        quantity,
        totalPrice: product.price * quantity,
        photoId: product.photoId ?? "",
        photoUrl: product.photoUrl,
        stock: product.stock,
        sellerId: product.sellerId,
        sellerName: product.sellerName,
      }
    : {
        productId,
        productTitle: "Ürün",
        price: 0,
        quantity,
        totalPrice: 0,
        photoId: "",
        photoUrl: "",
      };

  return recalcCart([...current.items, snapshot]);
}

export function optimisticUpdateItem(
  cart: Cart | undefined,
  productId: string,
  quantity: number,
): Cart {
  const current = cart ?? EMPTY_CART;
  const items = current.items.map((item) => {
    if (item.productId !== productId) return item;
    return {
      ...item,
      quantity,
      totalPrice: item.price * quantity,
    };
  });
  return recalcCart(items);
}

export function optimisticRemoveItem(
  cart: Cart | undefined,
  productId: string,
): Cart {
  const current = cart ?? EMPTY_CART;
  return recalcCart(
    current.items.filter((item) => item.productId !== productId),
  );
}

export function optimisticClearCart(): Cart {
  return { ...EMPTY_CART };
}
