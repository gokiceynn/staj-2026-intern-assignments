# AI (Gemini) Modülü

VBShop alışveriş asistanı — API key **yalnızca sunucuda** kullanılır.

**Ekip için detaylı rehber:** [`../../docs/AI_ASISTAN_EKIP_NOTU.md`](../../docs/AI_ASISTAN_EKIP_NOTU.md)

## Hızlı kurulum

1. [Google AI Studio](https://aistudio.google.com/apikey) → API key alın
2. `Web/.env.local`:

```env
GEMINI_API_KEY=buraya_keyinizi_yapistirin
GEMINI_MODEL=gemini-3.1-flash-lite
```

3. `npm run dev:reset`

## Klasör yapısı

```
src/
  lib/ai/           config.ts, gemini.ts
  features/ai/      api, queries, schemas, types
  app/api/ai/       chat/route.ts, status/route.ts
  components/ai/    AiAssistant.tsx
```

## Güvenlik

- Key'i commit'e veya `NEXT_PUBLIC_*` değişkenine koymayın
- Tüm istekler `/api/ai/chat` üzerinden sunucuda yapılır
