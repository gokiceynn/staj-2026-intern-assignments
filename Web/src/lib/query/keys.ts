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
  ai: {
    status: ["ai", "status"] as const,
  },
  reviews: {
    all: (productId: string) => ["reviews", productId] as const,
    list: (productId: string, params: Record<string, unknown>) =>
      ["reviews", productId, "list", params] as const,
  },
  metadata: {
    statuses: ["metadata", "statuses"] as const,
  },
  seller: {
    profile: ["seller", "profile"] as const,
    dashboard: (params: Record<string, unknown>) =>
      ["seller", "dashboard", params] as const,
    products: (params: Record<string, unknown>) =>
      ["seller", "products", params] as const,
    product: (id: string) => ["seller", "products", id] as const,
    orders: (params: Record<string, unknown>) =>
      ["seller", "orders", params] as const,
    order: (id: string) => ["seller", "orders", id] as const,
    carriers: ["seller", "carriers"] as const,
  },
  admin: {
    dashboard: (params: Record<string, unknown>) =>
      ["admin", "dashboard", params] as const,
    users: (params: Record<string, unknown>) =>
      ["admin", "users", params] as const,
    user: (id: string) => ["admin", "users", id] as const,
    sellers: (params: Record<string, unknown>) =>
      ["admin", "sellers", params] as const,
    seller: (id: string) => ["admin", "sellers", id] as const,
    orders: (params: Record<string, unknown>) =>
      ["admin", "orders", params] as const,
    order: (id: string) => ["admin", "orders", id] as const,
    carriers: ["admin", "carriers"] as const,
    carrier: (id: string) => ["admin", "carriers", id] as const,
  },
};
