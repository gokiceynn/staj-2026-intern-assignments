export const queryKeys = {
  auth: {
    me: ["auth", "me"] as const,
  },
  products: {
    all: ["products"] as const,
    list: (params: Record<string, unknown>) =>
      ["products", "list", params] as const,
    detail: (id: string) => ["products", "detail", id] as const,
  },
  categories: {
    all: ["categories"] as const,
  },
  cart: {
    all: ["cart"] as const,
  },
  orders: {
    all: ["orders"] as const,
    list: (params: Record<string, unknown>) =>
      ["orders", "list", params] as const,
    detail: (id: string) => ["orders", "detail", id] as const,
  },
  addresses: {
    all: ["addresses"] as const,
    detail: (id: string) => ["addresses", "detail", id] as const,
  },
  favorites: {
    all: ["favorites"] as const,
    list: (params: Record<string, unknown>) =>
      ["favorites", "list", params] as const,
    ids: ["favorites", "ids"] as const,
  },
};
