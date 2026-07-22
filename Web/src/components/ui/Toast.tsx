"use client";

import { useToast } from "@/components/ui/toast-context";
import { cn } from "@/lib/utils/cn";

const typeStyles = {
  success: "border-success bg-green-50 text-green-900 dark:bg-green-950 dark:text-green-100",
  error: "border-danger bg-red-50 text-red-900 dark:bg-red-950 dark:text-red-100",
  info: "border-brand-500 bg-brand-50 text-brand-700 dark:bg-brand-950 dark:text-brand-100",
};

export function ToastContainer() {
  const { toasts, dismissToast } = useToast();

  if (toasts.length === 0) return null;

  return (
    <div
      className="fixed right-4 top-4 z-[100] flex flex-col gap-2"
      aria-live="polite"
    >
      {toasts.map((toast) => (
        <div
          key={toast.id}
          role={toast.type === "error" ? "alert" : "status"}
          className={cn(
            "flex min-w-[280px] items-center justify-between gap-3 rounded-md border px-4 py-3 shadow-md",
            typeStyles[toast.type],
          )}
        >
          <span className="text-sm">{toast.message}</span>
          <button
            type="button"
            onClick={() => dismissToast(toast.id)}
            className="text-sm opacity-70 hover:opacity-100"
            aria-label="Kapat"
          >
            ✕
          </button>
        </div>
      ))}
    </div>
  );
}
