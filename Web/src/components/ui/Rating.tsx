import { cn } from "@/lib/utils/cn";

type RatingProps = {
  value: number;
  max?: number;
  className?: string;
};

export function Rating({ value, max = 5, className }: RatingProps) {
  return (
    <div className={cn("flex items-center gap-1", className)} aria-label={`${value} / ${max}`}>
      {Array.from({ length: max }, (_, i) => (
        <span
          key={i}
          className={cn(
            "text-sm",
            i < Math.round(value) ? "text-yellow-400" : "text-border",
          )}
        >
          ★
        </span>
      ))}
      <span className="text-xs text-text-muted">({value.toFixed(1)})</span>
    </div>
  );
}
