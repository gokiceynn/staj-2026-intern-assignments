import Link from "next/link";

const DEALS = [
  { label: "Süper Fırsat", href: "/products?sortBy=price_asc", emoji: "⚡", color: "bg-amber-100 text-amber-800" },
  { label: "Elektronik", href: "/products?q=elektronik", emoji: "📱", color: "bg-blue-100 text-blue-800" },
  { label: "Moda", href: "/products?q=moda", emoji: "👗", color: "bg-pink-100 text-pink-800" },
  { label: "Ev & Yaşam", href: "/products?q=ev", emoji: "🏠", color: "bg-green-100 text-green-800" },
  { label: "Yüksek Puan", href: "/products?sortBy=rating_desc", emoji: "⭐", color: "bg-violet-100 text-violet-800" },
  { label: "Yeni Gelenler", href: "/products?sortBy=newest", emoji: "🆕", color: "bg-cyan-100 text-cyan-800" },
];

export function QuickDealStrip() {
  return (
    <section aria-label="Hızlı kategoriler">
      <div className="flex gap-3 overflow-x-auto pb-1 scrollbar-hide">
        {DEALS.map((deal) => (
          <Link
            key={deal.label}
            href={deal.href}
            className="flex min-w-[88px] shrink-0 flex-col items-center gap-2 rounded-xl border border-border bg-surface p-3 shadow-card transition hover:border-brand-200 hover:shadow-md"
          >
            <span
              className={`flex h-12 w-12 items-center justify-center rounded-full text-xl ${deal.color}`}
            >
              {deal.emoji}
            </span>
            <span className="text-center text-xs font-medium leading-tight">
              {deal.label}
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
