# VBShop Web

VBShop B2C e-ticaret web uygulaması. Next.js 15 App Router, TanStack Query ve Tailwind CSS 4 ile geliştirilmiştir.

## Frontend Katkısı

| | |
|---|---|
| **Sorumlu** | Gökçen Usta |
| **Rol** | Frontend Web |
| **Teknolojiler** | Next.js 15, TypeScript, Tailwind CSS 4, TanStack Query, React Hook Form, Zod |
| **Tamamlanan temel işler** | 16 sayfa (ürün, auth, sepet, checkout, sipariş, profil), API sözleşmesine uygun BFF + cookie auth, kampanya odaklı ana sayfa/header, birim testler, CI pipeline |

Detaylı teslim ve devralma notları: **[docs/FRONTEND_HANDOFF.md](docs/FRONTEND_HANDOFF.md)**

## Gereksinimler

- Node.js 22+
- Backend API (`/api/v1`) — bkz. [`../Docs/ecommerce_api_contract_v1.3.md`](../Docs/ecommerce_api_contract_v1.3.md) ve `docs/API_ENDPOINT_MATRIX.md`

## Kurulum

```bash
cd Web
cp .env.example .env.local
npm install
npm run dev
```

Uygulama: [http://localhost:3000](http://localhost:3000)

## Ortam Değişkenleri

| Değişken | Açıklama |
|----------|----------|
| `API_BASE_URL` | Sunucu tarafı API (ör. `http://localhost:5000/api/v1`) |
| `NEXT_PUBLIC_API_BASE_URL` | İstemci referans URL |
| `NEXT_PUBLIC_APP_URL` | Uygulama kök URL |
| `OPENAPI_URL` | Swagger JSON (tip üretimi, opsiyonel) |

## OpenAPI tipleri

Backend Swagger'dan TypeScript tipleri otomatik üretilir (`openapi-typescript`):

```bash
npm run generate:types
```

- Kaynak: `openapi/openapi.snapshot.json` (API çalışıyorsa güncellenir)
- Çıktı: `src/types/api.generated.ts`
- Kolay import: `src/types/openapi.ts`
- **Mevcut `src/types/api.ts` aynı kalır** — uygulama davranışı değişmez

## Mimari

- **Sunucu:** Route Handlers (`/api/auth/*`, `/api/bff/*`) → Backend API
- **Kimlik doğrulama:** Access/refresh token httpOnly cookie
- **İstemci:** `apiClient` → `/api/bff/*` proxy
- **Durum:** TanStack Query (sunucu verisi)

Detay: `docs/ARCHITECTURE.md`

## API Sözleşmesi (v1.3)

Güncel kaynak: [`../Docs/ecommerce_api_contract_v1.3.md`](../Docs/ecommerce_api_contract_v1.3.md)

Frontend artık v1.3 endpointlerini kullanır:

- **Favoriler** — `GET/POST/DELETE /favorites`
- **Kategoriler** — `GET /categories`
- **Sepet silme** — `DELETE /cart/items/{productId}`, `DELETE /cart`
- **Hesap** — `GET/PUT /account/me`, adresler `GET/POST/PUT/DELETE /customer/me/addresses`
- **Kayıt** — `POST /auth/customer/register`

Detay: `docs/API_GAPS.md`

## Sayfalar

| Rota | Erişim |
|------|--------|
| `/`, `/products`, `/products/[id]` | Herkese açık |
| `/login`, `/register`, `/verify-email`, `/forgot-password`, `/reset-password` | Herkese açık |
| `/cart`, `/checkout`, `/order-success/[id]`, `/profile`, `/profile/addresses`, `/orders`, `/orders/[id]`, `/favorites` | Korumalı |

## Komutlar

```bash
npm run dev          # Geliştirme sunucusu
npm run build        # Production build
npm run lint         # ESLint
npm run typecheck    # TypeScript
npm run generate:types  # OpenAPI → api.generated.ts
npm run lighthouse      # Lighthouse raporu (önce npm run start)
npm run lighthouse:ci   # Lighthouse CI (lighthouserc.cjs)
npm run test         # Vitest birim testleri
npm run test:e2e     # Playwright E2E
npm run format       # Prettier
```

## Deploy

Vercel veya Netlify ile deploy: **[docs/DEPLOY.md](docs/DEPLOY.md)**

- `vercel.json` — Vercel (Root Directory: `Web`)
- `netlify.toml` — Netlify alternatifi

## Lighthouse

Hedef skorlar: Erişilebilirlik ≥90, Performans ≥70, SEO ≥85.

```bash
npm run build && npm run start   # terminal 1
npm run lighthouse               # terminal 2
```

Detay: `lighthouserc.cjs`, raporlar `lighthouse-reports/`

## Erişilebilirlik

- Skip link (`Ana içeriğe geç`), semantik `header` / `main` / `footer` / `nav`
- Klavye: Escape ile modal kapanır, `:focus-visible` stilleri
- `aria-*` etiketleri header, form ve toast bileşenlerinde
- `prefers-reduced-motion` ile animasyon azaltma

## Test

- **Vitest:** `src/**/*.test.{ts,tsx}`
- **Playwright:** `e2e/`
- CI: `.github/workflows/ci.yml`

## Güvenlik

- Token'lar yalnızca httpOnly cookie'de
- Refresh token asla localStorage'da tutulmaz
- BFF üzerinden otomatik token yenileme (tek uçuş mutex)
