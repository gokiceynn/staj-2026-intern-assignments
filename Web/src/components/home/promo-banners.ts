export type PromoBanner = {
  title: string;
  subtitle: string;
  href: string;
  gradientFrom: string;
  gradientTo: string;
  icon: "bolt" | "percent" | "shipping";
};

/** Mobil home_screen.dart ile aynı kampanya içeriği */
export const PROMO_BANNERS: PromoBanner[] = [
  {
    title: "Süper Fiyat Günleri",
    subtitle: "Seçili ürünlerde %40'a varan indirim",
    href: "/products?sortBy=price_asc",
    gradientFrom: "#FF6000",
    gradientTo: "#FF8F3C",
    icon: "bolt",
  },
  {
    title: "VB10 koduyla %10 indirim",
    subtitle: "Kupon kodunu sepette kullan",
    href: "/cart",
    gradientFrom: "#5D3EBC",
    gradientTo: "#8B6FE8",
    icon: "percent",
  },
  {
    title: "500 TL üzeri kargo bedava",
    subtitle: "Sepetini doldur, kargoyu düşünme",
    href: "/products",
    gradientFrom: "#0BA45C",
    gradientTo: "#3BC98A",
    icon: "shipping",
  },
];
