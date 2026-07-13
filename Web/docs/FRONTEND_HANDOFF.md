# Frontend Teslim Notları

Bu belge, VBShop projesine sonradan katılan bir ekip arkadaşının **Web/** (frontend) tarafını hızlıca devralabilmesi için hazırlanmıştır.

Kaynak sözleşme: `docs/ecommerce_api_contract_v1_detailed.pdf`  
Endpoint matrisi: `docs/API_ENDPOINT_MATRIX.md`  
Mimari özet: `docs/ARCHITECTURE.md`

---

## 1. Benim Sorumluluğum

**Gökçen Usta — Frontend / Web**

- B2C e-ticaret **web arayüzünün** geliştirilmesi (`Web/` klasörü)
- API sözleşmesine (PDF v1.0) uygun sayfa, bileşen ve kullanıcı akışları
- Auth cookie yönetimi, BFF proxy katmanı, TanStack Query entegrasyonu
- Responsive arayüz, açık/koyu tema, kampanya odaklı ana sayfa ve modern header tasarımı
- Teknik dokümantasyon (`docs/*`), birim test iskeleti, CI workflow
- **Kapsam dışı:** `Mobile/` (mobil ekip), `API/` backend implementasyonu, sözleşmede olmayan endpoint uydurma

---

## 2. Tamamlanan İşler

### Sayfalar ve akışlar

- Ana sayfa: kampanya slider, hızlı kategori şeridi, popüler / en beğenilen ürün bölümleri
- Ürün listeleme: arama, filtre, sıralama, sayfalama (URL query senkron)
- Ürün detay: miktar seçimi, sepete ekleme, favori (dev)
- Auth: kayıt → OTP doğrulama, giriş, çıkış, şifremi unuttum / sıfırlama
- Sepet: listeleme, miktar güncelleme (optimistic update)
- Checkout: adres seçimi + kart formu (Zod) → sipariş oluşturma
- Sipariş: geçmiş listesi, detay, iptal
- Profil: bilgi güncelleme, şifre değiştirme
- Adres yönetimi: CRUD
- Favoriler: dev-only localStorage fallback

### Altyapı

- Next.js 15 App Router + TypeScript strict
- Route Handlers: `/api/auth/*`, `/api/bff/*`
- httpOnly cookie tabanlı JWT oturumu + tek uçuş refresh mutex
- Ortak `ApiResponse<T>` zarfı parser’ı
- UI design system (Button, Input, Modal, Toast, ProductCard, vb.)
- GitHub Actions CI (lint, typecheck, test, build, Playwright)
- Vitest birim testleri (7 test)

---

## 3. Sayfalar

| Sayfa | Dosya yolu | Görev | API endpoint(ler) | Korumalı |
|-------|------------|-------|-----------------|----------|
| Ana sayfa | `src/app/page.tsx` | Kampanyalar + öne çıkan ürünler | `GET /products` (SSR, `fetchPublic`) | Hayır |
| Ürün listesi | `src/app/products/page.tsx` | Arama, filtre, sıralama, sepete ekle | `GET /products` | Hayır |
| Ürün detay | `src/app/products/[id]/page.tsx` | Ürün bilgisi, sepete ekle | `GET /products/{id}` | Hayır |
| Giriş | `src/app/login/page.tsx` | Oturum açma | `POST /auth/login` → `/api/auth/login` | Hayır |
| Kayıt | `src/app/register/page.tsx` | Hesap oluşturma | `POST /auth/register` | Hayır |
| E-posta doğrulama | `src/app/verify-email/page.tsx` | Kayıt OTP | `POST /auth/email/verify` | Hayır |
| Şifremi unuttum | `src/app/forgot-password/page.tsx` | Sıfırlama OTP başlat | `POST /auth/forgot-password` | Hayır |
| Şifre sıfırlama | `src/app/reset-password/page.tsx` | Yeni şifre + OTP | `POST /auth/reset-password` | Hayır |
| Sepet | `src/app/cart/page.tsx` | Sepet görüntüle / miktar güncelle | `GET /cart`, `PUT /cart/items/{productId}` | **Evet** |
| Checkout | `src/app/checkout/page.tsx` | Adres + ödeme + sipariş | `GET /cart`, `GET /users/me/addresses`, `POST /orders/checkout` | **Evet** |
| Sipariş başarı | `src/app/order-success/[id]/page.tsx` | Onay ekranı | `GET /orders/{id}` | **Evet** |
| Siparişler | `src/app/orders/page.tsx` | Sipariş geçmişi | `GET /orders` | **Evet** |
| Sipariş detay | `src/app/orders/[id]/page.tsx` | Detay + iptal | `GET /orders/{id}`, `POST /orders/{id}/cancel` | **Evet** |
| Profil | `src/app/profile/page.tsx` | Profil / şifre güncelle | `GET /users/me`, `PUT /users/me`, `PUT /users/me/password` | **Evet** |
| Adresler | `src/app/profile/addresses/page.tsx` | Adres CRUD | `GET/POST/PUT/DELETE /users/me/addresses` | **Evet** |
| Favoriler | `src/app/favorites/page.tsx` | Favori listesi (dev) | `GET /products` (filtre client-side) | **Evet** |

**Korumalı rota kontrolü:** `src/middleware.ts` — cookie yoksa `/login?redirect=...`

---

## 4. Önemli Bileşenler

| Bileşen | Konum | Görev | Kullanıldığı yerler |
|---------|-------|-------|---------------------|
| **Header** | `src/components/layout/Header.tsx` | Logo, arama, favori, hesap menüsü, sepet rozeti | `src/app/layout.tsx` |
| **CategoryNav** | `src/components/layout/CategoryNav.tsx` | Yatay kategori şeridi | Header altında |
| **Footer** | `src/components/layout/Footer.tsx` | Kurumsal / yardım linkleri | `src/app/layout.tsx` |
| **ProductCard** | `src/components/product/ProductCard.tsx` | Ürün kartı, fiyat, puan, sepete ekle, favori | Ana sayfa, ürün listesi, favoriler |
| **ProductGrid** | `src/components/product/ProductGrid.tsx` | Responsive ürün grid’i | Ana sayfa, `/products` |
| **HeroPromo** | `src/components/home/HeroPromo.tsx` | Kampanya slider | Ana sayfa |
| **QuickDealStrip** | `src/components/home/QuickDealStrip.tsx` | Hızlı kategori ikonları | Ana sayfa |
| **FeaturedProducts** | `src/components/home/FeaturedProducts.tsx` | Bölüm başlıklı ürün listesi + sepete ekle | Ana sayfa |
| **LoginForm** | `src/app/login/page.tsx` (sayfa içi) | Giriş formu + validasyon | `/login` |
| **Sepet satırı** | `src/app/cart/page.tsx` (sayfa içi) | Ürün satırı, miktar, ara toplam | `/cart` |
| **Button / Input / Modal** | `src/components/ui/*` | Design system primitives | Tüm formlar ve sayfalar |
| **Toast** | `src/components/ui/Toast.tsx` + `toast-context` | Genel bildirimler | Mutation hataları / başarı |

> **Not:** `CartItem` ve `LoginForm` ayrı dosya olarak çıkarılmadı; ilgili sayfa dosyalarının içinde tanımlıdır. İleride `src/components/cart/CartItem.tsx` ve `src/components/auth/LoginForm.tsx` olarak ayrılabilir.

---

## 5. API Entegrasyonu

### API istemcisi

| Katman | Dosya | Açıklama |
|--------|-------|----------|
| Sunucu (SSR) | `src/lib/api/server.ts` | `fetchPublic`, `fetchProtected` — doğrudan `API_BASE_URL` |
| İstemci (CSR) | `src/lib/api/client.ts` | `apiClient`, `authClient` → `/api/bff/*` ve `/api/auth/*` |
| Zarf parser | `src/lib/api/envelope.ts` | `parseApiResponse`, `ApiError`, `getFieldErrors` |
| Feature API | `src/features/*/api/*.ts` | Domain bazlı endpoint çağrıları |

### Token işlemleri

1. **Giriş / OTP doğrulama:** Route Handler cookie yazar (`src/app/api/auth/login/route.ts`, `verify-email/route.ts`).
2. **Cookie adları:** `vbshop_access_token`, `vbshop_refresh_token` (`src/lib/auth/cookies.ts`).
3. **Refresh:** `src/lib/auth/refresh-manager.ts` — eşzamanlı istekler tek promise paylaşır.
4. **BFF:** `src/app/api/bff/[...path]/route.ts` — 401’de refresh dener; başarısızsa cookie siler.
5. **Refresh token asla localStorage’da tutulmaz.**

### TanStack Query

- Provider: `src/components/providers.tsx`
- Query key’ler: `src/lib/query/keys.ts`
- Hook’lar: `src/features/*/queries/*.ts`
- Mutasyonlarda cache invalidation / optimistic update (ör. sepet)

### Hata gösterimi

- **Alan hataları:** `errors` objesi → React Hook Form `setError`
- **Genel mesaj:** `Toast` (`showToast`)
- **Sayfa düzeyi:** `ErrorState`, `EmptyState`, `Skeleton`

### Ortam değişkenleri

`.env.example` → kopyalanır: `.env.local`

| Değişken | Kullanım |
|----------|----------|
| `API_BASE_URL` | Sunucu tarafı (Route Handlers, SSR) |
| `NEXT_PUBLIC_API_BASE_URL` | İstemci referans (gerekli yerlerde) |
| `NEXT_PUBLIC_APP_URL` | Uygulama kök URL |

Base path: `/api/v1` (değişken değerinin içinde tanımlıdır, koda sabitlenmez).

---

## 6. Alınan Teknik Kararlar

| Teknoloji | Neden |
|-----------|-------|
| **Next.js App Router** | SSR/SEO (ürün sayfaları), Route Handlers ile güvenli cookie auth, dosya tabanlı routing |
| **TypeScript strict** | API sözleşmesi ile tip güvenliği, erken hata yakalama |
| **TanStack Query** | Sunucu state cache, mutation, optimistic update, loading/error durumları |
| **Tailwind CSS 4** | Hızlı responsive UI, merkezi design token’lar, açık/koyu tema |
| **React Hook Form + Zod** | Form performansı ve sözleşmeye uygun validasyon |
| **Zustand** | Bağımlılık eklendi; kart/ödeme verisi **bilinçli olarak** form state’te tutulur (localStorage/cookie’ye yazılmaz). Global UI store ihtiyacı olursa kullanıma hazır. |
| **BFF pattern** | Token’ların tarayıcı JS’ine sızmaması, merkezi refresh |

---

## 7. Eksik veya Bekleyen İşler

PDF sözleşmesinde **olmayan** veya henüz UI’ı tamamlanmamış özellikler:

| Özellik | Durum |
|---------|-------|
| **Favoriler API** | Yok → `LocalFavoritesRepository` yalnızca `development` |
| **Kategori listesi API** | Yok → ürün cevaplarından türetilir |
| **Sepetten silme** | Yok → production’da silme kapalı; `quantity=0` varsayılmaz |
| **Ürün yorumları** | Sözleşmede yok → UI yok |
| **Admin paneli** | Sözleşmede yok → kapsam dışı |
| **E-posta değiştirme + OTP** | API var, **profil UI henüz yok** |
| **Profil fotoğrafı yükleme** | `POST /photos` API var, **upload UI henüz yok** |
| **Hesap silme UI** | `useDeleteAccount` hook var, **sayfada buton yok** |
| **Figma tasarımı** | Repoda yok; özel e-ticaret UI tasarımı uygulandı |
| **E2E testler** | Playwright iskelet var; backend/mock ile genişletilmeli |
| **Demo video / deploy URL** | README alanları boş — teslim öncesi doldurulacak |

Detay: `docs/API_GAPS.md`

---

## 8. Bilinen Sorunlar

1. **Backend çalışmıyorsa** ürünler ve auth akışları boş/hata gösterir — bu beklenen davranıştır.
2. **macOS port 5000:** AirPlay Receiver aynı portu kullanabilir; backend için farklı port + `.env.local` güncellemesi gerekebilir.
3. **Dev sunucu hatası:** `.next` önbelleği bozulursa `rm -rf .next && npm run dev` yeterlidir. Turbopack devre dışı bırakıldı (`next dev` only).
4. **Favoriler production’da** kalıcı değildir; kullanıcıya dev ortamı dışında sınırlı deneyim sunulur.
5. **`POST /users/me/email/resend`** request body PDF’de eksik; backend netleşene kadar minimal çağrı.

---

## 9. Projeyi Devralacak Kişi İçin

1. `docs/ecommerce_api_contract_v1_detailed.pdf` ve `docs/API_ENDPOINT_MATRIX.md` oku.
2. `docs/API_GAPS.md` — uydurma endpoint yazma.
3. `Web/README.md` — kurulum ve komutlar.
4. `src/middleware.ts` — korumalı rotalar.
5. `src/lib/api/client.ts` + `src/app/api/bff/[...path]/route.ts` — istemci ↔ backend köprüsü.
6. `src/features/` — domain API + Query hook’ları.
7. Backend’i ayağa kaldır, `.env.local` ayarla, `npm run dev` ile test et.
8. Öncelikli geliştirme önerisi:
   - Profil: e-posta değiştirme OTP akışı
   - Profil: fotoğraf yükleme (`multipart/form-data`)
   - Hesap silme onay modalı
   - Sepet silme (backend endpoint gelince)
   - Favoriler gerçek API (endpoint gelince)
   - E2E testleri backend mock ile tamamlama
9. Değişiklikten sonra: `npm run lint && npm run typecheck && npm run test && npm run build`

### Kod yorumları

- Her satıra gereksiz yorum yazmayın.
- Sadece anlaşılması zor iş mantıklarında kısa ve açıklayıcı yorum kullanın (ör. refresh mutex, API gap fallback).

---

## 10. Çalıştırma

```bash
cd Web
cp .env.example .env.local   # API URL'lerini düzenle
npm install
npm run dev                  # http://localhost:3000
```

| Komut | Açıklama |
|-------|----------|
| `npm run dev` | Geliştirme sunucusu |
| `npm run build` | Production build |
| `npm run start` | Production sunucu |
| `npm run lint` | ESLint |
| `npm run typecheck` | TypeScript kontrol |
| `npm run test` | Vitest birim testleri |
| `npm run test:e2e` | Playwright E2E |
| `npm run format` | Prettier |

**Backend gereksinimi:** `API_BASE_URL` (ör. `http://localhost:5000/api/v1`) erişilebilir olmalıdır.

---

*Son güncelleme: VB10 Staj 2026 — Frontend Web teslimi*
