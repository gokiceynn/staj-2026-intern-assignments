import type { ProductQueryParams, ProductSortBy } from "@/types/api";

const SORT_VALUES: ProductSortBy[] = [
  "price_asc",
  "price_desc",
  "rating_desc",
  "newest",
];

export function buildProductQueryParams(
  params: ProductQueryParams,
): Record<string, string> {
  const query: Record<string, string> = {};

  if (params.page) query.page = String(params.page);
  if (params.size) query.size = String(params.size);
  if (params.q) query.q = params.q;
  if (params.categoryId) query.categoryId = params.categoryId;
  if (params.minPrice !== undefined) query.minPrice = String(params.minPrice);
  if (params.maxPrice !== undefined) query.maxPrice = String(params.maxPrice);
  if (params.sortBy) query.sortBy = params.sortBy;

  return query;
}

export function parseProductSearchParams(
  searchParams: Record<string, string | string[] | undefined>,
): ProductQueryParams {
  const get = (key: string) => {
    const value = searchParams[key];
    return Array.isArray(value) ? value[0] : value;
  };

  const sortRaw = get("sortBy");
  const sortBy = SORT_VALUES.includes(sortRaw as ProductSortBy)
    ? (sortRaw as ProductSortBy)
    : undefined;

  return {
    page: get("page") ? Number(get("page")) : 1,
    size: get("size") ? Number(get("size")) : 12,
    q: get("q") || undefined,
    categoryId: get("categoryId") || undefined,
    minPrice: get("minPrice") ? Number(get("minPrice")) : undefined,
    maxPrice: get("maxPrice") ? Number(get("maxPrice")) : undefined,
    sortBy,
  };
}

export function productQueryToSearchString(params: ProductQueryParams): string {
  const sp = new URLSearchParams(buildProductQueryParams(params));
  return sp.toString();
}
