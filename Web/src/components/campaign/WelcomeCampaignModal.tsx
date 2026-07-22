"use client";

import { useCallback, useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { cn } from "@/lib/utils/cn";

/** Tüm overlay konumları bu tuval oranına göre yüzde ile hesaplanır — ekran boyutundan bağımsız */
const CAMPAIGN_CANVAS = {
  src: "/anaekran.png",
  width: 1448,
  height: 1086,
  alt: "VBShop kampanya — yeni üyelik fırsatı",
} as const;

const LEAF_DECORATIONS = {
  topLeft: {
    src: "/solust.svg",
    width: 843,
    height: 536,
    left: "-6%",
    top: "-14%",
    widthPercent: "40%",
    sway: "leaf-sway leaf-sway--delay-1 leaf-sway--origin-tl",
  },
  topRight: {
    src: "/sagust.svg",
    width: 566,
    height: 695,
    right: "-10%",
    top: "-14%",
    widthPercent: "30%",
    sway: "leaf-sway leaf-sway--alt leaf-sway--delay-2 leaf-sway--origin-tr",
  },
  bottomLeft: {
    src: "/solalt.svg",
    width: 793,
    height: 838,
    left: "-11%",
    bottom: "-14%",
    widthPercent: "34%",
    sway: "leaf-sway leaf-sway--slow leaf-sway--delay-3 leaf-sway--origin-bl",
  },
  bottomRight: {
    src: "/sagalt.svg",
    width: 1920,
    height: 1280,
    right: "-8%",
    bottom: "-10%",
    widthPercent: "73%",
    sway: "leaf-sway leaf-sway--alt leaf-sway--origin-br",
  },
} as const;

/** Görseldeki "HEMEN KAYIT OL" pill butonuna hizalı tıklama alanı */
const REGISTER_HOTSPOT = {
  left: "9.8%",
  top: "68.3%",
  width: "32.5%",
  height: "8.8%",
} as const;

type LeafDecorProps = {
  src: string;
  width: number;
  height: number;
  widthPercent: string;
  sway: string;
  className?: string;
  style?: React.CSSProperties;
};

function LeafDecor({
  src,
  width,
  height,
  widthPercent,
  sway,
  className,
  style,
}: LeafDecorProps) {
  return (
    <div
      aria-hidden="true"
      className={cn("pointer-events-none absolute", className)}
      style={{ width: widthPercent, ...style }}
    >
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={src}
        alt=""
        width={width}
        height={height}
        className={cn(
          sway,
          "block h-auto w-full max-w-none object-contain",
        )}
      />
    </div>
  );
}

export function WelcomeCampaignModal() {
  const { data: user, isPending } = useCurrentUser();
  const [open, setOpen] = useState(false);

  const closeModal = useCallback(() => {
    setOpen(false);
  }, []);

  useEffect(() => {
    if (isPending) return;
    if (user) return;
    setOpen(true);
  }, [isPending, user]);

  useEffect(() => {
    if (!open) return;

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") closeModal();
    };

    document.addEventListener("keydown", onKeyDown);
    document.body.style.overflow = "hidden";

    return () => {
      document.removeEventListener("keydown", onKeyDown);
      document.body.style.overflow = "";
    };
  }, [open, closeModal]);

  if (!open) return null;

  const { topLeft, topRight, bottomLeft, bottomRight } = LEAF_DECORATIONS;

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center overflow-y-auto p-4 sm:p-6"
      role="presentation"
    >
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        aria-hidden
      />

      <div
        role="dialog"
        aria-modal="true"
        aria-label="VBShop karşılama kampanyası"
        className="relative z-10 my-auto w-full max-w-[1200px]"
      >
        <div className="relative mx-auto w-full">
          <button
            type="button"
            onClick={closeModal}
            className={cn(
              "absolute -right-1 -top-1 z-20 flex h-9 w-9 items-center justify-center rounded-full",
              "bg-surface text-lg leading-none text-text shadow-md transition",
              "hover:bg-surface-muted focus-visible:outline focus-visible:outline-2",
              "focus-visible:outline-brand-500 focus-visible:outline-offset-2",
              "sm:right-2 sm:top-2",
            )}
            aria-label="Kampanyayı kapat"
          >
            ×
          </button>

          <div
            className="relative w-full overflow-hidden rounded-lg shadow-2xl"
            style={{
              aspectRatio: `${CAMPAIGN_CANVAS.width} / ${CAMPAIGN_CANVAS.height}`,
            }}
          >
            <Image
              src={CAMPAIGN_CANVAS.src}
              alt={CAMPAIGN_CANVAS.alt}
              priority
              fill
              className="z-0 object-contain"
              sizes="(max-width: 1200px) 100vw, 1200px"
            />

            <LeafDecor
              src={topLeft.src}
              width={topLeft.width}
              height={topLeft.height}
              widthPercent={topLeft.widthPercent}
              sway={topLeft.sway}
              className="z-[1]"
              style={{ left: topLeft.left, top: topLeft.top }}
            />

            <LeafDecor
              src={topRight.src}
              width={topRight.width}
              height={topRight.height}
              widthPercent={topRight.widthPercent}
              sway={topRight.sway}
              className="z-10"
              style={{ right: topRight.right, top: topRight.top }}
            />

            <LeafDecor
              src={bottomLeft.src}
              width={bottomLeft.width}
              height={bottomLeft.height}
              widthPercent={bottomLeft.widthPercent}
              sway={bottomLeft.sway}
              className="z-10"
              style={{ left: bottomLeft.left, bottom: bottomLeft.bottom }}
            />

            <LeafDecor
              src={bottomRight.src}
              width={bottomRight.width}
              height={bottomRight.height}
              widthPercent={bottomRight.widthPercent}
              sway={bottomRight.sway}
              className="z-[2]"
              style={{ right: bottomRight.right, bottom: bottomRight.bottom }}
            />

            <Link
              href="/register"
              onClick={closeModal}
              style={{
                left: REGISTER_HOTSPOT.left,
                top: REGISTER_HOTSPOT.top,
                width: REGISTER_HOTSPOT.width,
                height: REGISTER_HOTSPOT.height,
              }}
              className={cn(
                "absolute z-[3] cursor-pointer overflow-hidden rounded-full",
                "bg-transparent transition-all duration-300",
                "hover:bg-brand-500/45 hover:shadow-[inset_0_0_0_2px_rgba(255,96,0,1),0_0_32px_rgba(255,96,0,0.75)]",
                "focus-visible:bg-brand-500/45 focus-visible:outline-none",
                "focus-visible:shadow-[inset_0_0_0_2px_rgba(255,96,0,1),0_0_32px_rgba(255,96,0,0.75)]",
              )}
              aria-label="Yeni üyelik için kayıt ol"
            />
          </div>
        </div>
      </div>
    </div>
  );
}
