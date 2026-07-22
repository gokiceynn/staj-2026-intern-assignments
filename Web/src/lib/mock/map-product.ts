import type { MockCategory, MockProduct } from "@/lib/mock/types";
import type { ProductDetail, ProductListItem } from "@/types/api";

function categoryName(categories: MockCategory[], categoryId: string) {
  return categories.find((c) => c.id === categoryId)?.name ?? categoryId;
}

export function mockDiscountPercent(product: MockProduct) {
  if (product.originalPrice == null || product.originalPrice <= product.price) {
    return 0;
  }
  return Math.round(100 * (1 - product.price / product.originalPrice));
}

export function toProductListItem(
  product: MockProduct,
  categories: MockCategory[],
): ProductListItem {
  return {
    id: product.id,
    title: product.name,
    brand: product.brand,
    description: product.description,
    price: product.price,
    originalPrice: product.originalPrice,
    stock: product.stock,
    photoId: product.id,
    photoUrl: product.images[0] ?? "",
    rating: product.rating,
    reviewCount: product.reviewCount,
    freeShipping: product.freeShipping,
    seller: product.seller,
    isFlashDeal: product.isFlashDeal,
    isFeatured: product.isFeatured,
    category: {
      id: product.categoryId,
      name: categoryName(categories, product.categoryId),
    },
  };
}

export function toProductDetail(
  product: MockProduct,
  categories: MockCategory[],
): ProductDetail {
  const base = toProductListItem(product, categories);
  return {
    id: base.id,
    title: base.brand ? `${base.brand} ${base.title}` : base.title,
    description: base.description,
    price: base.price,
    stock: base.stock,
    photoId: base.photoId,
    photoUrl: base.photoUrl,
    rating: base.rating,
    features: {
      Marka: product.brand,
      Satıcı: product.seller,
      ...(product.freeShipping ? { Kargo: "Bedava" } : {}),
    },
    categoryId: product.categoryId,
  };
}
