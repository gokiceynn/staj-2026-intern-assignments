import type { Paginated } from "@/types/api";

const EMPTY_PAGINATED: Paginated<never> = {
  items: [],
  pageIndex: 1,
  pageSize: 0,
  totalCount: 0,
  totalPages: 0,
};

/** Backend bazen `{ page: { items, page, pageSize... } }` döner; frontend düz `Paginated` bekler. */
export function normalizePaginated<T>(data: unknown): Paginated<T> {
  if (!data || typeof data !== "object") {
    return { ...EMPTY_PAGINATED };
  }

  const record = data as Record<string, unknown>;

  if (Array.isArray(record.items)) {
    return {
      items: record.items as T[],
      pageIndex: Number(record.pageIndex ?? record.page ?? 1),
      pageSize: Number(record.pageSize ?? record.items.length),
      totalCount: Number(record.totalCount ?? record.items.length),
      totalPages: Number(record.totalPages ?? 1),
    };
  }

  const page = record.page;
  if (page && typeof page === "object") {
    const nested = page as Record<string, unknown>;
    const items = Array.isArray(nested.items) ? (nested.items as T[]) : [];

    return {
      items,
      pageIndex: Number(nested.page ?? nested.pageIndex ?? 1),
      pageSize: Number(nested.pageSize ?? items.length),
      totalCount: Number(nested.totalCount ?? items.length),
      totalPages: Number(nested.totalPages ?? 0),
    };
  }

  return { ...EMPTY_PAGINATED };
}
