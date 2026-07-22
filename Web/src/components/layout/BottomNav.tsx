"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { useCartItemCount } from "@/features/cart/queries/use-cart";
import { cn } from "@/lib/utils/cn";

const ITEMS = [
  { href: "/", label: "Ana Sayfa", icon: "🏠", match: (p: string) => p === "/" },
  {
    href: "/products",
    label: "Kategoriler",
    icon: "▦",
    match: (p: string) => p.startsWith("/products"),
  },
  { href: "/cart", label: "Sepetim", icon: "🛒", match: (p: string) => p.startsWith("/cart") },
  {
    href: "/favorites",
    label: "Favoriler",
    icon: "♥",
    match: (p: string) => p.startsWith("/favorites"),
  },
  {
    href: "/profile",
    label: "Hesabım",
    icon: "👤",
    match: (p: string) =>
      p.startsWith("/profile") ||
      p.startsWith("/login") ||
      p.startsWith("/orders"),
  },
] as const;

export function BottomNav() {
  const pathname = usePathname();
  const { data: user } = useCurrentUser();
  const cartCount = useCartItemCount();

  return (
    <nav
      aria-label="Ana menü"
      className="fixed inset-x-0 bottom-0 z-50 border-t border-border bg-surface/95 backdrop-blur md:hidden"
    >
      <ul className="mx-auto flex max-w-lg items-stretch justify-around px-1 pb-[env(safe-area-inset-bottom)] pt-1">
        {ITEMS.map((item) => {
          const active = item.match(pathname);
          const href =
            item.href === "/profile" && !user ? "/login?redirect=/profile" : item.href;

          return (
            <li key={item.label} className="flex-1">
              <Link
                href={href}
                className={cn(
                  "relative flex min-h-[52px] flex-col items-center justify-center gap-0.5 text-[10px] font-medium transition",
                  active ? "text-brand-500" : "text-text-muted",
                )}
              >
                <span className="text-lg leading-none" aria-hidden>
                  {item.icon}
                </span>
                <span>{item.label}</span>
                {item.href === "/cart" && cartCount > 0 && (
                  <span className="absolute right-[calc(50%-18px)] top-1 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-brand-500 px-1 text-[9px] font-bold text-white">
                    {cartCount > 99 ? "99+" : cartCount}
                  </span>
                )}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
