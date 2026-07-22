"use client";

import { useTheme } from "@/lib/theme/provider";
import { cn } from "@/lib/utils/cn";

export function ThemeFloatingToggle() {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === "dark";

  return (
    <button
      type="button"
      onClick={toggleTheme}
      className={cn(
        "fixed left-3 z-40 flex h-12 w-12 flex-col items-center justify-center rounded-full border border-border bg-surface text-xl shadow-md transition hover:scale-105 hover:shadow-lg focus-visible:outline focus-visible:outline-2 focus-visible:outline-brand-500 sm:left-4 sm:h-14 sm:w-14 sm:text-2xl",
        "bottom-20 md:bottom-auto md:top-1/2 md:-translate-y-1/2",
        isDark && "border-brand-500/40 bg-surface-muted",
      )}
      aria-label={isDark ? "Gündüz moduna geç" : "Gece moduna geç"}
      title={isDark ? "Gündüz modu" : "Gece modu"}
    >
      <span aria-hidden>{isDark ? "☀️" : "💡"}</span>
    </button>
  );
}
