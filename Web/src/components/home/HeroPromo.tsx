"use client";

import Link from "next/link";
import { useState } from "react";
import { ChevronLeftIcon, ChevronRightIcon } from "@/components/ui/icons";

const SLIDES = [
  {
    id: 1,
    title: "Süper Fırsatlar",
    subtitle: "Seçili ürünlerde kaçırılmayacak indirimler",
    cta: "Keşfet",
    href: "/products?sortBy=price_asc",
    gradient: "from-brand-600 via-orange-500 to-amber-500",
  },
  {
    id: 2,
    title: "Elektronik Günleri",
    subtitle: "Telefon, kulaklık ve daha fazlası",
    cta: "Elektronik",
    href: "/products?q=elektronik",
    gradient: "from-violet-600 via-purple-600 to-indigo-600",
  },
  {
    id: 3,
    title: "500 TL Üzeri Kargo Bedava",
    subtitle: "Sepetinizi doldurun, kargo bizden",
    cta: "Alışverişe Başla",
    href: "/products",
    gradient: "from-emerald-600 via-teal-600 to-cyan-600",
  },
];

export function HeroPromo() {
  const [active, setActive] = useState(0);
  const slide = SLIDES[active];

  const prev = () => setActive((i) => (i === 0 ? SLIDES.length - 1 : i - 1));
  const next = () => setActive((i) => (i === SLIDES.length - 1 ? 0 : i + 1));

  return (
    <section className="grid gap-4 lg:grid-cols-[1fr_280px]">
      <div className="relative overflow-hidden rounded-xl">
        <div
          className={`flex min-h-[220px] flex-col justify-center bg-gradient-to-r px-8 py-10 text-white md:min-h-[280px] md:px-12 ${slide.gradient}`}
        >
          <p className="text-sm font-medium uppercase tracking-wide text-white/80">
            VBShop Kampanyalar
          </p>
          <h2 className="mt-2 text-2xl font-bold md:text-4xl">{slide.title}</h2>
          <p className="mt-2 max-w-md text-sm text-white/90 md:text-base">
            {slide.subtitle}
          </p>
          <Link
            href={slide.href}
            className="mt-6 inline-flex w-fit items-center rounded-lg bg-white px-6 py-2.5 text-sm font-semibold text-brand-600 shadow-md transition hover:bg-brand-50"
          >
            {slide.cta}
          </Link>
        </div>
        <button
          type="button"
          onClick={prev}
          className="absolute left-3 top-1/2 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full bg-white/90 text-text shadow-md hover:bg-white"
          aria-label="Önceki kampanya"
        >
          <ChevronLeftIcon className="h-5 w-5" />
        </button>
        <button
          type="button"
          onClick={next}
          className="absolute right-3 top-1/2 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full bg-white/90 text-text shadow-md hover:bg-white"
          aria-label="Sonraki kampanya"
        >
          <ChevronRightIcon className="h-5 w-5" />
        </button>
        <div className="absolute bottom-4 left-1/2 flex -translate-x-1/2 gap-2">
          {SLIDES.map((s, i) => (
            <button
              key={s.id}
              type="button"
              onClick={() => setActive(i)}
              className={`h-2 rounded-full transition-all ${
                i === active ? "w-6 bg-white" : "w-2 bg-white/50"
              }`}
              aria-label={`Kampanya ${i + 1}`}
            />
          ))}
        </div>
      </div>

      <div className="hidden flex-col gap-4 lg:flex">
        <Link
          href="/products?sortBy=rating_desc"
          className="flex flex-1 flex-col justify-center rounded-xl bg-gradient-to-br from-deal to-pink-600 p-6 text-white shadow-md transition hover:opacity-95"
        >
          <span className="text-xs font-semibold uppercase">Flaş Fırsat</span>
          <span className="mt-1 text-lg font-bold">En Beğenilenler</span>
          <span className="mt-1 text-sm text-white/80">Yüksek puanlı ürünler</span>
        </Link>
        <Link
          href="/favorites"
          className="flex flex-1 flex-col justify-center rounded-xl border border-border bg-surface p-6 shadow-card transition hover:border-brand-200 hover:shadow-md"
        >
          <span className="text-xs font-semibold text-brand-600">Favorilerim</span>
          <span className="mt-1 text-lg font-bold">Listeni Oluştur</span>
          <span className="mt-1 text-sm text-text-muted">Beğendiğin ürünleri kaydet</span>
        </Link>
      </div>
    </section>
  );
}
