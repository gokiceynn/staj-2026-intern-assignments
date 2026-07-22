import categoriesJson from "@/data/categories.json";
import productsJson from "@/data/products.json";
import {
  mockDiscountPercent,
  toProductDetail,
  toProductListItem,
} from "@/lib/mock/map-product";
import type {
  MockCategory,
  MockProduct,
  MockProductQuery,
  MockProductSort,
} from "@/lib/mock/types";
import type { Paginated, ProductDetail, ProductListItem } from "@/types/api";

const categories = categoriesJson as MockCategory[];
const products = productsJson as MockProduct[];

function fold(value: string) {
  return value.toLocaleLowerCase("tr-TR");
}

function sortProducts(items: MockProduct[], sort: MockProductSort) {
  const sorted = [...items];
  switch (sort) {
    case "featured":
      sorted.sort((a, b) => {
        const featured = Number(b.isFeatured) - Number(a.isFeatured);
        return featured !== 0 ? featured : b.rating - a.rating;
      });
      break;
    case "priceAsc":
      sorted.sort((a, b) => a.price - b.price);
      break;
    case "priceDesc":
      sorted.sort((a, b) => b.price - a.price);
      break;
    case "ratingDesc":
      sorted.sort((a, b) => b.rating - a.rating);
      break;
    case "newest":
      sorted.sort(
        (a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
      );
      break;
    case "discount":
      sorted.sort(
        (a, b) => mockDiscountPercent(b) - mockDiscountPercent(a),
      );
      break;
  }
  return sorted;
}

function queryMockProducts(query: MockProductQuery) {
  const page = query.page ?? 1;
  const size = query.size ?? 20;
  const sort = query.sort ?? "featured";

  let results = products.filter((product) => {
    if (query.categoryId && product.categoryId !== query.categoryId) {
      return false;
    }
    if (query.q?.trim()) {
      const needle = fold(query.q.trim());
      const haystack = fold(`${product.name} ${product.brand} ${product.seller}`);
      if (!haystack.includes(needle)) return false;
    }
    if (query.minPrice != null && product.price < query.minPrice) return false;
    if (query.maxPrice != null && product.price > query.maxPrice) return false;
    if (query.minRating != null && product.rating < query.minRating) return false;
    if (query.inStockOnly && product.stock <= 0) return false;
    if (query.flashDealsOnly && !product.isFlashDeal) return false;
    if (query.featuredOnly && !product.isFeatured) return false;
    return true;
  });

  results = sortProducts(results, sort);

  const totalCount = results.length;
  const totalPages = totalCount === 0 ? 1 : Math.ceil(totalCount / size);
  const start = (page - 1) * size;
  const slice = start >= totalCount ? [] : results.slice(start, start + size);

  return {
    items: slice.map((p) => toProductListItem(p, categories)),
    pageIndex: page,
    pageSize: size,
    totalCount,
    totalPages,
  } satisfies Paginated<ProductListItem>;
}

export const mockCatalogApi = {
  listCategories: (): MockCategory[] => categories,

  listProducts: (query: MockProductQuery = {}): Paginated<ProductListItem> =>
    queryMockProducts(query),

  getProduct: (id: string): ProductDetail | null => {
    const product = products.find((item) => item.id === id);
    if (!product) return null;
    return toProductDetail(product, categories);
  },

  flashDeals: () =>
    queryMockProducts({
      flashDealsOnly: true,
      sort: "discount",
      page: 1,
      size: 12,
    }).items,

  featured: () =>
    queryMockProducts({
      featuredOnly: true,
      sort: "featured",
      page: 1,
      size: 12,
    }).items,

  topRated: () =>
    queryMockProducts({
      sort: "ratingDesc",
      page: 1,
      size: 6,
    }).items,
};

export function parseMockProductQuery(
  searchParams: Record<string, string | string[] | undefined>,
): MockProductQuery {
  const get = (key: string) => {
    const value = searchParams[key];
    return Array.isArray(value) ? value[0] : value;
  };

  const sortRaw = get("sortBy") ?? get("sort");
  const sortMap: Record<string, MockProductSort> = {
    featured: "featured",
    price_asc: "priceAsc",
    priceAsc: "priceAsc",
    price_desc: "priceDesc",
    priceDesc: "priceDesc",
    rating_desc: "ratingDesc",
    ratingDesc: "ratingDesc",
    newest: "newest",
    discount: "discount",
  };

  const isFlash = get("flash") === "1" || get("flashDeal") === "true";
  const isFeatured = get("featured") === "true";

  return {
    q: get("q") || undefined,
    categoryId: get("categoryId") || get("category") || undefined,
    minPrice: get("minPrice") ? Number(get("minPrice")) : undefined,
    maxPrice: get("maxPrice") ? Number(get("maxPrice")) : undefined,
    minRating: get("minRating") ? Number(get("minRating")) : undefined,
    inStockOnly: get("inStock") === "true",
    flashDealsOnly: isFlash,
    featuredOnly: isFeatured,
    sort: sortMap[sortRaw ?? ""] ?? (isFlash ? "discount" : "featured"),
    page: get("page") ? Number(get("page")) : 1,
    size: get("size") ? Number(get("size")) : 12,
  };
}
