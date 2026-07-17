# Frontend Teslim Notları

Bu belge, VBShop projesine sonradan katılan bir ekip arkadaşının **Web/** (frontend) tarafını hızlıca devralabilmesi için hazırlanmıştır.

Kaynak sözleşme: [`Docs/ecommerce_api_contract_v1.3.md`](../../Docs/ecommerce_api_contract_v1.3.md)  
Endpoint matrisi: `docs/API_ENDPOINT_MATRIX.md`  
Mimari özet: `docs/ARCHITECTURE.md`  
**AI asistan rehberi:** `docs/AI_ASISTAN_EKIP_NOTU.md`

---

## 1. Benim Sorumluluğum

**Gökçen Usta — Frontend / Web**

- B2C e-ticaret **web arayüzünün** geliştirilmesi (`Web/` klasörü)
- API sözleşmesi **v1.3** uyumlu sayfa, bileşen ve kullanıcı akışları
- Auth cookie yönetimi, BFF proxy katmanı, TanStack Query entegrasyonu
- Responsive arayüz, açık/koyu tema, kampanya odaklı ana sayfa ve modern header tasarımı
- Teknik dokümantasyon (`docs/*`), birim test iskeleti, CI workflow
- **Kapsam dışı:** `API/` backend implementasyonu, sözleşmede olmayan endpoint uydurma

---

## 2. Tamamlanan İşler

### Sayfalar ve akışlar

- Ana sayfa: kampanya slider, hızlı kategori şeridi, öne çıkan ürün bölümleri
- Ürün listeleme: arama, filtre, sıralama, sayfalama (URL query senkron)
- Ürün detay: miktar seçimi, sepete ekleme, favori (API)
- Auth: kayıt (`/auth/customer/register`) → OTP → giriş, çıkış, şifre sıfırlama
- Sepet: listeleme, miktar güncelleme, ürün silme, sepeti temizleme
- Checkout: adres seçimi + kart formu → sipariş
- Sipariş: geçmiş, detay, iptal
- Profil: bilgi ve şifre güncelleme
- Adres yönetimi: CRUD (`/customer/me/addresses`)
- Favoriler: `GET/POST/DELETE /favorites`
- Kategoriler: `GET /categories`

### Altyapı

- Next.js 15 App Router + TypeScript strict
- Route Handlers: `/api/auth/*`, `/api/bff/*`
- httpOnly cookie JWT + tek uçuş refresh mutex
- GitHub Actions CI, Vitest (7 test)

---

## 3. Sayfalar

| Sayfa | Dosya yolu | Görev | API endpoint(ler) | Korumalı |
|-------|------------|-------|-----------------|----------|
| Ana sayfa | `src/app/page.tsx` | Kampanyalar + ürünler | `GET /products` | Hayır |
| Ürün listesi | `src/app/products/page.tsx` | Arama, filtre, sıralama | `GET /products`, `GET /categories` | Hayır |
| Ürün detay | `src/app/products/[id]/page.tsx` | Detay, sepete ekle, favori | `GET /products/{id}` | Hayır |
| Giriş | `src/app/login/page.tsx` | Oturum açma | `POST /auth/login` | Hayır |
| Kayıt | `src/app/register/page.tsx` | Hesap oluşturma | `POST /auth/customer/register` | Hayır |
| E-posta doğrulama | `src/app/verify-email/page.tsx` | Kayıt OTP | `POST /auth/email/verify` | Hayır |
| Şifremi unuttum | `src/app/forgot-password/page.tsx` | OTP başlat | `POST /auth/forgot-password` | Hayır |
| Şifre sıfırlama | `src/app/reset-password/page.tsx` | Yeni şifre | `POST /auth/reset-password` | Hayır |
| Sepet | `src/app/cart/page.tsx` | Sepet CRUD | `GET/PUT/DELETE /cart`, `/cart/items/{id}` | **Evet** |
| Checkout | `src/app/checkout/page.tsx` | Sipariş | `GET /cart`, `GET /customer/me/addresses`, `POST /orders/checkout` | **Evet** |
| Siparişler | `src/app/orders/page.tsx` | Geçmiş | `GET /orders` | **Evet** |
| Sipariş detay | `src/app/orders/[id]/page.tsx` | Detay + iptal | `GET /orders/{id}`, `POST /orders/{id}/cancel` | **Evet** |
| Profil | `src/app/profile/page.tsx` | Profil / şifre | `GET/PUT /account/me`, `PUT /account/me/password` | **Evet** |
| Adresler | `src/app/profile/addresses/page.tsx` | Adres CRUD | `/customer/me/addresses` | **Evet** |
| Favoriler | `src/app/favorites/page.tsx` | Favori listesi | `GET /favorites` | **Evet** |

**Korumalı rota:** `src/middleware.ts`

---

## 4. Önemli Bileşenler

| Bileşen | Konum | Görev |
|---------|-------|-------|
| **Header** | `src/components/layout/Header.tsx` | Arama, favori, sepet, kategori nav |
| **ProductCard** | `src/components/product/ProductCard.tsx` | Ürün kartı + favori + sepete ekle |
| **BackendNoticeBanner** | `src/components/layout/BackendNoticeBanner.tsx` | Geçici backend uyarısı (API hazır olunca kaldır) |

---

## 5. API Entegrasyonu

- İstemci: `src/lib/api/client.ts` → `/api/bff/*`
- Auth route: `src/app/api/auth/*` → upstream v1.3
- Kayıt upstream: `/auth/customer/register` (`/api/auth/register` proxy)
- Profil: `/account/me` · Adres: `/customer/me/addresses`
- Token: httpOnly cookie; refresh: `src/lib/auth/refresh-manager.ts`

---

## 6. Alınan Teknik Kararlar

Next.js 15, TypeScript, TanStack Query, Tailwind 4, React Hook Form + Zod, BFF + cookie auth.

---

## 7. Eksik veya Bekleyen İşler (UI)

| Özellik | Durum |
|---------|-------|
| Ürün yorumları | API var, UI yok |
| E-posta değiştirme OTP | API var, UI yok |
| Hesap silme butonu | API var (`DELETE /customer/me`), UI yok |
| `GET /metadata/statuses` | Sipariş etiketleri UI’da yok |
| Checkout `Idempotency-Key` | Header henüz eklenmedi |
| E2E testler | İskelet var |
| Backend uyarı şeridi | API hazır olunca kaldırılacak |

Detay: `docs/API_GAPS.md`

---

## 8. Bilinen Sorunlar

1. Backend kapalıysa ürün/auth hata gösterir (beklenen).
2. macOS port 5000 AirPlay çakışması olabilir.
3. Dev sunucu CSS bozulursa: `npm run dev:reset`

---

## 9. Projeyi Devralacak Kişi İçin

1. [`Docs/ecommerce_api_contract_v1.3.md`](../../Docs/ecommerce_api_contract_v1.3.md) ve `docs/API_ENDPOINT_MATRIX.md`
2. `docs/API_GAPS.md`
3. `src/app/api/bff/[...path]/route.ts`
4. `src/features/`

### Kod yorumları

- Her satıra gereksiz yorum yazmayın.
- Sadece anlaşılması zor iş mantıklarında kısa yorum kullanın.

---

## 10. Çalıştırma

```bash
cd Web
cp .env.example .env.local
npm install
npm run dev
```

| Komut | Açıklama |
|-------|----------|
| `npm run dev` | Geliştirme (port 3000) |
| `npm run dev:reset` | Cache temizle + tek sunucu başlat |
| `npm run build` | Production build |
| `npm run lint` | ESLint |
| `npm run typecheck` | TypeScript |
| `npm run test` | Vitest |

---

*Son güncelleme: VB10 Staj 2026 — Frontend Web · API v1.3*
