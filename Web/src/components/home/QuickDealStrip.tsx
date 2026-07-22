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
      <div className="mx-auto grid w-full max-w-6xl grid-cols-2 gap-4 px-4 py-1 sm:grid-cols-3 lg:grid-cols-6 xl:gap-5">
        {DEALS.map((deal) => (
          <Link
            key={deal.label}
            href={deal.href}
            className="flex h-full min-h-[160px] w-full max-w-[240px] flex-col items-center justify-center gap-4 rounded-[1.25rem] border border-border bg-surface px-4 py-5 text-center shadow-xl transition duration-300 hover:-translate-y-1 hover:border-brand-200 hover:shadow-2xl"
          >
            <span
              className={`flex h-14 w-14 items-center justify-center rounded-full text-2xl ${deal.color}`}
            >
              {deal.emoji}
            </span>
            <span className="max-w-[10rem] text-sm font-semibold leading-tight text-text">
              {deal.label}
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
