"use client";

import { useTheme } from "@/lib/theme/provider";
import { Button } from "@/components/ui/Button";

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <Button
      variant="ghost"
      size="sm"
      onClick={toggleTheme}
      aria-label={theme === "light" ? "Koyu moda geç" : "Açık moda geç"}
    >
      {theme === "light" ? "🌙" : "☀️"}
    </Button>
  );
}
