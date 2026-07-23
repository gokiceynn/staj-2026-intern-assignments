import type { ProductListItem } from "@/types/api";

export const PET_DEAL_CAMPAIGN = {
  id: "pet-deal",
  code: "PETSEVER25",
  title: "Kedi & Köpek Fırsatları",
  categoryId: "cat_supermarket",
} as const;

const PET_PATTERN =
  /köpek|kedi|pet|hayvan maması|kuru mama|yaş mama|mama kabı|tasma|kum|akvaryum/i;

export function isPetProduct(product: Pick<ProductListItem, "title" | "description">): boolean {
  const text = `${product.title} ${product.description}`.toLocaleLowerCase("tr-TR");
  if (PET_PATTERN.test(text)) return true;
  return text.includes("mama") && (text.includes("köpek") || text.includes("kedi"));
}

const DISCOUNT_TIERS = [10, 15, 20, 25, 30] as const;

export function getPetDealDiscountPercent(productId: string): number {
  let hash = 0;
  for (let i = 0; i < productId.length; i++) {
    hash = (hash + productId.charCodeAt(i)) % 997;
  }
  return DISCOUNT_TIERS[hash % DISCOUNT_TIERS.length]!;
}

export function applyDiscount(price: number, percent: number): number {
  return Math.round(price * (1 - percent / 100) * 100) / 100;
}

export function filterPetProducts(products: ProductListItem[]): ProductListItem[] {
  return products.filter(isPetProduct);
}
