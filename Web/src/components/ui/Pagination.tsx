import { cn } from "@/lib/utils/cn";

type PaginationProps = {
  pageIndex: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  className?: string;
};

export function Pagination({
  pageIndex,
  totalPages,
  onPageChange,
  className,
}: PaginationProps) {
  if (totalPages <= 1) return null;

  return (
    <nav
      className={cn("flex items-center justify-center gap-2", className)}
      aria-label="Sayfalama"
    >
      <button
        type="button"
        onClick={() => onPageChange(pageIndex - 1)}
        disabled={pageIndex <= 1}
        className="rounded-md border border-border px-3 py-1.5 text-sm disabled:opacity-50"
      >
        Önceki
      </button>
      <span className="text-sm text-text-muted">
        {pageIndex} / {totalPages}
      </span>
      <button
        type="button"
        onClick={() => onPageChange(pageIndex + 1)}
        disabled={pageIndex >= totalPages}
        className="rounded-md border border-border px-3 py-1.5 text-sm disabled:opacity-50"
      >
        Sonraki
      </button>
    </nav>
  );
}
