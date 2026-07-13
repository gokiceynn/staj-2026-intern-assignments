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
- Backend API (`/api/v1`) — bkz. `docs/API_ENDPOINT_MATRIX.md`

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

## Mimari

- **Sunucu:** Route Handlers (`/api/auth/*`, `/api/bff/*`) → Backend API
- **Kimlik doğrulama:** Access/refresh token httpOnly cookie
- **İstemci:** `apiClient` → `/api/bff/*` proxy
- **Durum:** TanStack Query (sunucu verisi)

Detay: `docs/ARCHITECTURE.md`

## API Boşlukları (GAPS)

PDF sözleşmesinde olmayan özellikler için frontend **sahte endpoint üretmez**:

1. **Favoriler** — Yalnızca `development` ortamında `localStorage` (`LocalFavoritesRepository`)
2. **Kategoriler** — Ürün listesinden türetilir; `categoryId` filtresi API'ye iletilir
3. **Sepetten silme** — `DELETE` yok; production'da silme devre dışı

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
npm run test         # Vitest birim testleri
npm run test:e2e     # Playwright E2E
npm run format       # Prettier
```

## Test

- **Vitest:** `src/**/*.test.{ts,tsx}`
- **Playwright:** `e2e/`
- CI: `.github/workflows/ci.yml`

## Güvenlik

- Token'lar yalnızca httpOnly cookie'de
- Refresh token asla localStorage'da tutulmaz
- BFF üzerinden otomatik token yenileme (tek uçuş mutex)
