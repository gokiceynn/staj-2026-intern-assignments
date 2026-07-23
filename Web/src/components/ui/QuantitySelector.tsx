"use client";

import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/utils/cn";

type QuantitySelectorProps = {
  value: number;
  min?: number;
  max?: number;
  onChange: (value: number) => void;
  disabled?: boolean;
  className?: string;
};

export function QuantitySelector({
  value,
  min = 1,
  max = 99,
  onChange,
  disabled,
  className,
}: QuantitySelectorProps) {
  return (
    <div className={cn("inline-flex items-center gap-1", className)}>
      <Button
        variant="outline"
        size="sm"
        onClick={() => onChange(Math.max(min, value - 1))}
        disabled={disabled || value <= min}
        aria-label="Azalt"
      >
        −
      </Button>
      <span className="w-8 text-center text-sm font-medium">{value}</span>
      <Button
        variant="outline"
        size="sm"
        onClick={() => onChange(Math.min(max, value + 1))}
        disabled={disabled || value >= max}
        aria-label="Artır"
      >
        +
      </Button>
    </div>
  );
}
