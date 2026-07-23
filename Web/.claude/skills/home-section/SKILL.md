---
name: home-section
description: >-
  VBShop Web ana sayfasına yeni ürün bölümü ekler — SectionHeader + ProductRail
  (mobil) veya FeaturedProducts (masaüstü), API fetch, boş/hata durumları.
  "Ana sayfaya bölüm ekle", "ürün rayı", "home section" taleplerinde kullan.
---

# /home-section — Ana Sayfa Ürün Bölümü

VBShop **Web/** projesinde ana sayfaya tekrarlayan ürün bölümü ekler.
**Mobile/ klasörüne dokunma.**

## Ne zaman kullanılır?

- Ana sayfaya yeni ürün rayı veya grid bölümü eklenecek
- "Süper Fırsatlar", "Öne Çıkanlar" benzeri bir section isteniyor
- API'den ürün listesi çekilip gösterilecek

## Mevcut bileşenler (yeniden kullan)

| Bileşen | Dosya | Kullanım |
|---------|-------|----------|
| `SectionHeader` | `src/components/home/SectionHeader.tsx` | Başlık + "Tümünü Gör" linki |
| `ProductRail` | `src/components/home/ProductRail.tsx` | Yatay kaydırmalı kartlar (mobil) |
| `FeaturedProducts` | `src/components/home/FeaturedProducts.tsx` | Grid + sepete ekle (masaüstü) |
| `ProductGrid` | `src/components/product/ProductGrid.tsx` | Mobil grid (En Beğenilenler) |
| `ProductCard` | `src/components/product/ProductCard.tsx` | `variant="rail"` mobil ray için |

## API kalıbı (server component — `page.tsx`)

```typescript
import { fetchPublic, productListPath } from "@/lib/api/server";
import { normalizePaginated } from "@/lib/api/pagination";
import { withPhotoUrls } from "@/lib/utils/photo-url";
import type { ProductListItem } from "@/types/api";

// Örnek: en düşük fiyatlı 8 ürün
const data = await fetchPublic<unknown>(
  productListPath({ page: 1, size: 8, sortBy: "price_asc" }),
);
const items = withPhotoUrls(normalizePaginated<ProductListItem>(data).items);
```

**sortBy değerleri:** `price_asc` | `price_desc` | `newest` | `rating_desc`

Mock endpoint veya uydurma alan **ekleme** — yalnızca mevcut API sözleşmesi.

## Mobil bölüm (`HomeMobileSections.tsx`)

```tsx
{items.length > 0 && (
  <>
    <SectionHeader title="Bölüm Başlığı" href="/products?sortBy=price_asc" />
    <ProductRail products={items} />
  </>
)}
```

- Bölüm yalnızca `md:hidden` kapsayıcı içinde kalır
- Boş liste → bölümü **render etme** (`length > 0` guard)
- Yeni prop: `HomeMobileSectionsProps`'a ekle, `page.tsx`'ten geçir

## Masaüstü bölüm (`page.tsx` — `hidden md:block` bloğu)

```tsx
<FeaturedProducts
  title="Bölüm Başlığı"
  products={items}
  viewAllHref="/products?sortBy=price_asc"
/>
```

- `FeaturedProducts` boş array'de zaten `null` döner
- API hatasında mevcut dashed border empty state korunur

## Zorunlu kurallar

1. **Mobile/ dokunma** — yalnızca `Web/src/`
2. **Boş / yükleniyor / hata** — ürün yoksa bölüm gizle; API yoksa mevcut empty state
3. **Tema token'ları** — `text-text`, `text-brand-600`, `border-border`, `bg-surface`
4. **Foto URL** — her zaman `withPhotoUrls()` kullan
5. **Kapsam** — sadece istenen bölüm; ilgisiz dosyalara diff açma

## Adımlar (checklist)

```
- [ ] page.tsx: yeni fetch + değişken (Promise.all'a ekle)
- [ ] page.tsx: HomeMobileSections'a yeni prop
- [ ] HomeMobileSections.tsx: SectionHeader + ProductRail bloğu
- [ ] page.tsx: masaüstü FeaturedProducts (gerekirse)
- [ ] viewAllHref query string API sortBy ile uyumlu
- [ ] npm run typecheck
```

## Örnek çağrı

```
/home-section
Başlık: "En Yeni Ürünler"
sortBy: newest
size: 8
viewAllHref: /products?sortBy=newest
Mobil ve masaüstü ana sayfaya ekle.
```

## Beklenen çıktı

- `Web/src/app/page.tsx` — fetch + prop geçişi
- `Web/src/components/home/HomeMobileSections.tsx` — mobil ray
- (Opsiyonel) masaüstü `FeaturedProducts` satırı
- Typecheck hatasız

## Demo notu

"Her yeni ana sayfa bölümünde aynı 4 dosyayı ve API kalıbını tekrar anlatıyordum.
Bu skill ile SectionHeader + ProductRail + fetch tek seferde geliyor."
