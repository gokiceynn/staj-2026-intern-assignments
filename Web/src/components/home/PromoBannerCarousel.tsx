"use client";

import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";
import { PROMO_BANNERS } from "@/components/home/promo-banners";
import { cn } from "@/lib/utils/cn";

function BannerIcon({ type }: { type: (typeof PROMO_BANNERS)[number]["icon"] }) {
  const className = "h-14 w-14 text-white/85";

  if (type === "bolt") {
    return (
      <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
        <path d="M11 21h-1l1-7H7.5c-.58 0-.57-.32-.38-.66.19-.34.05-.08.07-.12C8.48 10.94 10.42 7.54 13 3h1l-1 7h3.5c.49 0 .56.33.3.73l-3.8 6.05c-.02.04-.04.08-.06.11L11 21z" />
      </svg>
    );
  }

  if (type === "percent") {
    return (
      <svg className={className} viewBox="0 0 24 24" fill="none" aria-hidden>
        <circle cx="7" cy="7" r="2.5" stroke="currentColor" strokeWidth="2" />
        <circle cx="17" cy="17" r="2.5" stroke="currentColor" strokeWidth="2" />
        <path d="m5 19 14-14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
      </svg>
    );
  }

  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M3 7h11v8H3V7Zm11 2h4l3 3v3h-7V9ZM6 18a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Zm10 0a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
    </svg>
  );
}

type PromoBannerCarouselProps = {
  className?: string;
};

export function PromoBannerCarousel({ className }: PromoBannerCarouselProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [active, setActive] = useState(0);

  const scrollToIndex = useCallback((index: number) => {
    const container = scrollRef.current;
    if (!container) return;
    const slide = container.children[index] as HTMLElement | undefined;
    slide?.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
    setActive(index);
  }, []);

  useEffect(() => {
    const timer = window.setInterval(() => {
      setActive((current) => {
        const next = (current + 1) % PROMO_BANNERS.length;
        const container = scrollRef.current;
        const slide = container?.children[next] as HTMLElement | undefined;
        slide?.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
        return next;
      });
    }, 4000);
    return () => window.clearInterval(timer);
  }, []);

  const handleScroll = () => {
    const container = scrollRef.current;
    if (!container || container.children.length === 0) return;
    const slideWidth = (container.children[0] as HTMLElement).offsetWidth;
    if (slideWidth <= 0) return;
    const index = Math.round(container.scrollLeft / slideWidth);
    setActive(Math.min(Math.max(index, 0), PROMO_BANNERS.length - 1));
  };

  return (
    <section aria-label="Kampanyalar" className={cn("pt-3", className)}>
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className="scrollbar-hide flex snap-x snap-mandatory overflow-x-auto scroll-smooth px-4"
      >
        {PROMO_BANNERS.map((banner) => (
          <div key={banner.title} className="min-w-full shrink-0 snap-center">
            <Link
              href={banner.href}
              className="flex h-[140px] items-center overflow-hidden rounded-2xl px-5 text-white shadow-md transition hover:opacity-95"
              style={{
                background: `linear-gradient(to right, ${banner.gradientFrom}, ${banner.gradientTo})`,
              }}
            >
              <div className="flex-1 pr-3">
                <p className="text-[18px] font-black leading-tight">{banner.title}</p>
                <p className="mt-1 text-[13px] text-white/70">{banner.subtitle}</p>
              </div>
              <BannerIcon type={banner.icon} />
            </Link>
          </div>
        ))}
      </div>

      <div className="mt-2 flex justify-center gap-1.5">
        {PROMO_BANNERS.map((banner, i) => (
          <button
            key={banner.title}
            type="button"
            aria-label={`Kampanya ${i + 1}`}
            onClick={() => scrollToIndex(i)}
            className={cn(
              "h-1.5 rounded-full transition-all duration-200",
              i === active ? "w-[18px] bg-brand-500" : "w-1.5 bg-border",
            )}
          />
        ))}
      </div>
    </section>
  );
}

/** @deprecated PromoBannerCarousel kullanın */
export const MobileBannerCarousel = PromoBannerCarousel;
