# Deploy — VBShop Web

Web uygulamasını production ortamına almak için adımlar.

## Gereksinimler

- Node.js 22+
- Çalışan backend API (`API_BASE_URL`)
- GitHub repo erişimi

## Vercel (önerilen)

1. [vercel.com](https://vercel.com) → **Add New Project** → GitHub repo seç
2. **Root Directory:** `Web`
3. Framework: **Next.js** (otomatik algılanır, `vercel.json` mevcut)
4. **Environment Variables** ekle:

| Değişken | Örnek | Zorunlu |
|----------|--------|---------|
| `API_BASE_URL` | `https://api.example.com/api/v1` | Evet |
| `NEXT_PUBLIC_API_BASE_URL` | Aynı URL | Evet |
| `NEXT_PUBLIC_APP_URL` | `https://vbshop.vercel.app` | Evet |
| `GEMINI_API_KEY` | (AI asistan için) | Hayır |

5. **Deploy**

> Not: Backend fotoğrafları için `next.config.ts` içinde production API hostname'i `images.remotePatterns`'a eklenmelidir.

## Netlify (alternatif)

1. Netlify → **Add new site** → GitHub repo
2. **Base directory:** `Web`
3. Build: `npm run build` (`netlify.toml` mevcut)
4. Aynı ortam değişkenlerini Netlify dashboard'dan ekleyin

## Yerel production testi

```bash
cd Web
cp .env.example .env.local
npm ci
npm run build
npm run start
```

Uygulama: http://localhost:3000

## Lighthouse skorları

Production build çalışırken:

```bash
npm run lighthouse
```

Hedef skorlar (`lighthouserc.cjs`):

| Kategori | Hedef |
|----------|--------|
| Erişilebilirlik | ≥ 90 |
| Performans | ≥ 70 |
| Best Practices | ≥ 85 |
| SEO | ≥ 85 |

Lighthouse CI:

```bash
npm run start   # ayrı terminal
npm run lighthouse:ci
```

Raporlar: `Web/lighthouse-reports/`

## CI

GitHub Actions (`Web/.github/workflows/ci.yml`): lint, typecheck, test, build, E2E.

Lighthouse CI yerelde çalıştırılır; API backend gerektiren sayfalar deploy ortamında test edilmelidir.
