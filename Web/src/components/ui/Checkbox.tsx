import { cn } from "@/lib/utils/cn";
import type { InputHTMLAttributes } from "react";

type CheckboxProps = Omit<InputHTMLAttributes<HTMLInputElement>, "type"> & {
  label: string;
};

export function Checkbox({ className, label, id, ...props }: CheckboxProps) {
  const checkboxId = id ?? label.toLowerCase().replace(/\s+/g, "-");

  return (
    <label
      htmlFor={checkboxId}
      className={cn("flex cursor-pointer items-center gap-2 text-sm", className)}
    >
      <input
        id={checkboxId}
        type="checkbox"
        className="h-4 w-4 rounded border-border text-brand-600 focus:ring-brand-500"
        {...props}
      />
      <span>{label}</span>
    </label>
  );
}
