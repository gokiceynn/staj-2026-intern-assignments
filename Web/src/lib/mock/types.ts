export type MockCategory = {
  id: string;
  name: string;
  icon: string;
};

export type MockProduct = {
  id: string;
  name: string;
  brand: string;
  description: string;
  categoryId: string;
  price: number;
  originalPrice: number | null;
  images: string[];
  rating: number;
  reviewCount: number;
  stock: number;
  seller: string;
  freeShipping: boolean;
  isFlashDeal: boolean;
  isFeatured: boolean;
  createdAt: string;
};

export type MockProductSort =
  | "featured"
  | "priceAsc"
  | "priceDesc"
  | "ratingDesc"
  | "newest"
  | "discount";

export type MockProductQuery = {
  q?: string;
  categoryId?: string;
  minPrice?: number;
  maxPrice?: number;
  minRating?: number;
  inStockOnly?: boolean;
  flashDealsOnly?: boolean;
  featuredOnly?: boolean;
  sort?: MockProductSort;
  page?: number;
  size?: number;
};
