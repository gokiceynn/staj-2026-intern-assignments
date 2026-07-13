# Architecture

## Overview

VBShop Web, Next.js App Router ile B2C e-ticaret arayüzüdür. Tüm iş kuralları backend API sözleşmesine (`/api/v1`) bağlıdır.

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
    product/ cart/ ...    # Domain UI
  features/
    auth/ products/ cart/ orders/ users/ addresses/ favorites/
      api/ queries/ mutations/ schemas/ components/ types/
  lib/
    api/                  # client, server, envelope parser
    auth/                 # cookies, session, refresh mutex
    query/                # TanStack Query provider
    validation/           # Shared Zod schemas
    utils/
  hooks/
  stores/                 # Zustand (UI-only, no card/token storage)
  types/
```

## Auth & tokens

- Access + refresh token: **httpOnly**, **Secure** (prod), **SameSite=Lax** cookies.
- Refresh token **asla** localStorage’da tutulmaz.
- `lib/auth/refresh-manager.ts`: tek uçuş refresh (concurrent istekler aynı promise’i bekler).
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

## Favorites (gap)

`FavoritesRepository` interface → `LocalFavoritesRepository` (dev-only). Swap-ready for future API.

## Categories (gap)

Derived from product `category` fields in list responses; cached in query client. Not authoritative.

## Cart remove (gap)

No DELETE endpoint → remove UI disabled in production; no `quantity=0` hack.

## Testing

- **Vitest:** envelope, zod, utils, components (MSW).
- **Playwright:** critical flows against dev server + MSW or mock BFF.
- Production bundle MSW’ye bağlı değil.

## CI

GitHub Actions: `npm ci` → lint → typecheck → unit tests → build → Playwright.
