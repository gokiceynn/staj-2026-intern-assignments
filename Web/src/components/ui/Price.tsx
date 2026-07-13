import { formatCurrency } from "@/lib/utils/format";
import { cn } from "@/lib/utils/cn";

type PriceProps = {
  amount: number;
  className?: string;
  size?: "sm" | "md" | "lg";
};

const sizes = {
  sm: "text-sm",
  md: "text-base font-semibold",
  lg: "text-xl font-bold",
};

export function Price({ amount, className, size = "md" }: PriceProps) {
  return (
    <span className={cn("text-brand-600", sizes[size], className)}>
      {formatCurrency(amount)}
    </span>
  );
}
