# Architecture

## Overview

VBShop Web, Next.js App Router ile B2C e-ticaret arayüzüdür. Tüm iş kuralları backend API sözleşmesine ([`Docs/ecommerce_api_contract_v1.3.md`](../../Docs/ecommerce_api_contract_v1.3.md), `/api/v1`) bağlıdır.

```
Browser
  ├── Server Components → serverApi (API_BASE_URL + cookies)
  └── Client Components → /api/bff/* Route Handlers → Backend API
                              ↑ httpOnly cookies (access/refresh)
```

## Directory layout

```
src/
  app/                    # Routes, layouts, Route Handlers
  components/
    ui/                   # Design system primitives
    layout/               # Header, Footer, ThemeToggle
    product/ home/        # Domain UI
  features/
    auth/ products/ cart/ orders/ users/ addresses/ favorites/ categories/
      api/ queries/ schemas/
  lib/
    api/                  # client, server, envelope parser
    auth/                 # cookies, session, refresh mutex
    query/                # TanStack Query keys
  types/
```

## Auth & tokens

- Access + refresh token: **httpOnly**, **Secure** (prod), **SameSite=Lax** cookies.
- Refresh token **asla** localStorage’da tutulmaz.
- Kayıt: `POST /auth/customer/register` (BFF: `/api/auth/register` → upstream customer register).
- Profil: `GET /account/me`; adresler: `/customer/me/addresses`; hesap silme: `DELETE /customer/me`.
- Login response: `account` (route handler istemciye `user` olarak map eder).
- `lib/auth/refresh-manager.ts`: tek uçuş refresh mutex.
- Refresh başarısız → cookies temizlenir → `/login?redirect=...`.

## API client rules

1. Tek merkezi envelope parser: `parseApiResponse<T>()`.
2. Field-level errors → form `setError`.
3. Genel `message` → toast / alert region.
4. Photo GET: ayrı binary handler, envelope yok.

## Server vs client

| Use Server Component | Use Client Component |
|---------------------|----------------------|
| Initial product list/detail SEO | Cart mutations, forms |
| Metadata generation | TanStack Query hooks |
| Protected layout session check | Filters, debounce, modals |

## Favorites

`features/favorites/api/favorites-api.ts` — `GET/POST/DELETE /favorites` (Customer, korumalı).

## Categories

`features/categories/api/categories-api.ts` — `GET /categories` (anonim, ağaç yapısı).

## Cart

`DELETE /cart/items/{productId}` ve `DELETE /cart` desteklenir.

## Henüz UI’da olmayan sözleşme özellikleri

- Ürün yorumları (`/products/{id}/reviews`)
- `GET /metadata/statuses` (sipariş durum etiketleri)
- Checkout `Idempotency-Key` header
- Profil e-posta OTP ve hesap silme ekranları

## Testing

- **Vitest:** envelope, utils, components.
- **Playwright:** critical flows.
- Production bundle MSW’ye bağlı değil.

## CI

GitHub Actions: `npm ci` → lint → typecheck → unit tests → build → Playwright.
