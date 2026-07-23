"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useState, FormEvent, Suspense } from "react";
import { CategoryNav } from "@/components/layout/CategoryNav";
import { ThemeToggle } from "@/components/layout/ThemeToggle";
import { useCurrentUser, useLogout } from "@/features/auth/queries/use-auth";
import { useCartItemCount } from "@/features/cart/queries/use-cart";
import { useRootCategories } from "@/features/categories/queries/use-categories";
import { useToast } from "@/components/ui/toast-context";
import {
  SearchIcon,
  CartIcon,
  UserIcon,
  HeartIcon,
} from "@/components/ui/icons";
import { cn } from "@/lib/utils/cn";

function HeaderContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [search, setSearch] = useState(searchParams.get("q") ?? "");
  const [mobileOpen, setMobileOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  const { data: user } = useCurrentUser();
  const logout = useLogout();
  const cartCount = useCartItemCount();
  const { data: categories } = useRootCategories();
  const { showToast } = useToast();

  const handleSearch = (e: FormEvent) => {
    e.preventDefault();
    const params = new URLSearchParams();
    if (search.trim()) params.set("q", search.trim());
    router.push(`/products?${params.toString()}`);
    setMobileOpen(false);
  };

  const handleLogout = async () => {
    try {
      await logout.mutateAsync();
      showToast("Çıkış yapıldı", "success");
      router.push("/");
      router.refresh();
    } catch {
      showToast("Çıkış yapılamadı", "error");
    }
  };

  return (
    <header className="sticky top-0 z-40 bg-surface shadow-sm">
      <div className="mx-auto max-w-7xl px-4">
        <div className="flex items-center gap-3 py-3 md:gap-4">
          <Link
            href="/"
            className="shrink-0 text-2xl font-extrabold tracking-tight text-brand-600"
          >
            VBShop
          </Link>

          <form
            onSubmit={handleSearch}
            className="hidden flex-1 items-stretch md:flex"
          >
            <div className="flex flex-1 overflow-hidden rounded-lg border-2 border-brand-500 bg-surface">
              <input
                type="search"
                placeholder="Ürün, kategori veya marka ara"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="min-h-[44px] flex-1 px-4 text-sm outline-none"
                aria-label="Ürün ara"
              />
              <button
                type="submit"
                className="flex min-w-[52px] items-center justify-center bg-brand-500 text-white transition hover:bg-brand-600"
                aria-label="Ara"
              >
                <SearchIcon className="h-5 w-5" />
              </button>
            </div>
          </form>

          <div className="ml-auto flex items-center gap-1 md:gap-2">
            <ThemeToggle />

            <Link
              href="/favorites"
              className="hidden min-h-[44px] min-w-[44px] flex-col items-center justify-center rounded-lg px-2 text-text-muted hover:bg-surface-muted hover:text-brand-600 sm:flex"
              aria-label="Favoriler"
            >
              <HeartIcon className="h-6 w-6" />
              <span className="text-[10px] font-medium">Favoriler</span>
            </Link>

            <div className="relative">
              <button
                type="button"
                onClick={() => setMenuOpen(!menuOpen)}
                className="flex min-h-[44px] min-w-[44px] flex-col items-center justify-center rounded-lg px-2 text-text-muted hover:bg-surface-muted hover:text-brand-600"
                aria-expanded={menuOpen}
                aria-label="Hesabım"
              >
                <UserIcon className="h-6 w-6" />
                <span className="hidden max-w-[72px] truncate text-[10px] font-medium sm:block">
                  {user ? user.firstName : "Giriş Yap"}
                </span>
              </button>
              {menuOpen && (
                <>
                  <div
                    className="fixed inset-0 z-40"
                    onClick={() => setMenuOpen(false)}
                    aria-hidden
                  />
                  <div className="absolute right-0 z-50 mt-1 w-52 rounded-lg border border-border bg-surface py-1 shadow-lg">
                    {user ? (
                      <>
                        <p className="border-b border-border px-4 py-2 text-sm font-medium">
                          Merhaba, {user.firstName}
                        </p>
                        <Link
                          href="/profile"
                          className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                          onClick={() => setMenuOpen(false)}
                        >
                          Profilim
                        </Link>
                        <Link
                          href="/orders"
                          className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                          onClick={() => setMenuOpen(false)}
                        >
                          Siparişlerim
                        </Link>
                        <Link
                          href="/profile/addresses"
                          className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                          onClick={() => setMenuOpen(false)}
                        >
                          Adreslerim
                        </Link>
                        {user.role === "Seller" && (
                          <Link
                            href="/seller"
                            className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                            onClick={() => setMenuOpen(false)}
                          >
                            Satıcı Paneli
                          </Link>
                        )}
                        {user.role === "Admin" && (
                          <Link
                            href="/admin"
                            className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                            onClick={() => setMenuOpen(false)}
                          >
                            Admin Paneli
                          </Link>
                        )}
                        <button
                          type="button"
                          className="block w-full px-4 py-2.5 text-left text-sm text-danger hover:bg-surface-muted"
                          onClick={handleLogout}
                        >
                          Çıkış Yap
                        </button>
                      </>
                    ) : (
                      <>
                        <Link
                          href="/login"
                          className="block px-4 py-2.5 text-sm font-medium text-brand-600 hover:bg-surface-muted"
                          onClick={() => setMenuOpen(false)}
                        >
                          Giriş Yap
                        </Link>
                        <Link
                          href="/register"
                          className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                          onClick={() => setMenuOpen(false)}
                        >
                          Kayıt Ol
                        </Link>
                        <Link
                          href="/register/seller"
                          className="block px-4 py-2.5 text-sm hover:bg-surface-muted"
                          onClick={() => setMenuOpen(false)}
                        >
                          Satıcı Kaydı
                        </Link>
                      </>
                    )}
                  </div>
                </>
              )}
            </div>

            <Link
              href="/cart"
              className="relative flex min-h-[44px] min-w-[44px] flex-col items-center justify-center rounded-lg px-2 text-text-muted hover:bg-surface-muted hover:text-brand-600"
              aria-label={`Sepetim${cartCount > 0 ? `, ${cartCount} ürün` : ""}`}
            >
              <CartIcon className="h-6 w-6" />
              <span className="text-[10px] font-medium">Sepetim</span>
              {cartCount > 0 && (
                <span className="absolute right-0 top-0 flex h-5 min-w-[20px] items-center justify-center rounded-full bg-brand-500 px-1 text-[10px] font-bold text-white">
                  {cartCount > 99 ? "99+" : cartCount}
                </span>
              )}
            </Link>

            <button
              type="button"
              className="flex min-h-[44px] min-w-[44px] items-center justify-center rounded-lg md:hidden"
              onClick={() => setMobileOpen(!mobileOpen)}
              aria-label="Menü"
              aria-expanded={mobileOpen}
            >
              <span className="text-xl">{mobileOpen ? "✕" : "☰"}</span>
            </button>
          </div>
        </div>

        <div className={cn("pb-3 md:hidden", mobileOpen ? "block" : "hidden")}>
          <form onSubmit={handleSearch}>
            <div className="flex overflow-hidden rounded-lg border-2 border-brand-500">
              <input
                type="search"
                placeholder="Ürün ara..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="min-h-[44px] flex-1 px-4 text-sm outline-none"
              />
              <button
                type="submit"
                className="bg-brand-500 px-4 text-white"
                aria-label="Ara"
              >
                <SearchIcon className="h-5 w-5" />
              </button>
            </div>
          </form>
        </div>
      </div>

      <CategoryNav categories={categories} />
    </header>
  );
}

export function Header() {
  return (
    <Suspense
      fallback={
        <header className="h-[120px] border-b border-border bg-surface shadow-sm" />
      }
    >
      <HeaderContent />
    </Suspense>
  );
}
