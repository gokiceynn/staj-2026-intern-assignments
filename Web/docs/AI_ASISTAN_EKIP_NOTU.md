# VBShop AI Asistan — Ekip Bilgilendirme Notu

Bu belge, web uygulamasına eklenen **Google Gemini tabanlı alışveriş asistanının** proje arkadaşları tarafından anlaşılması için hazırlanmıştır.

**Ekleyen:** Gökçen Usta — Frontend / Web  
**Konum:** `Web/` klasörü  
**Backend bağımlılığı:** Yok — AI, Gemini API'ye doğrudan sunucu tarafından bağlanır

---

## 1. Bu Özellik Ne Yapar?

VBShop sitesinin sağ alt köşesinde turuncu **AI** butonu vardır. Kullanıcı buna tıklayınca bir sohbet penceresi açılır ve alışverişle ilgili sorular sorabilir:

- *"Sepetime nasıl ürün eklerim?"*
- *"Siparişimi nasıl takip ederim?"*
- *"Favorilere nasıl eklerim?"*

Asistan **Türkçe** yanıt verir. Site kullanımı hakkında yardımcı olur; stok, fiyat veya sipariş durumu sorulduğunda gerçek veriye erişemediğini belirtir (tahmin uydurmaz).

---

## 2. Neden Böyle Tasarlandı?

| Karar | Açıklama |
|-------|----------|
| **Sunucu tarafı çağrı** | API key tarayıcıya hiç gitmez |
| **BFF pattern** | İstemci yalnızca `/api/ai/*` endpoint'lerini bilir |
| **`.env.local`** | Her geliştirici kendi key'ini kullanır; GitHub'a gitmez |
| **Opsiyonel** | Key yoksa asistan görünür ama mesaj gönderilemez |
| **E-ticaret API'den bağımsız** | Backend kapalı olsa bile AI çalışabilir (key varsa) |

---

## 3. Kullanıcı Arayüzü

- **Buton:** Sağ alt köşe, turuncu yuvarlak "AI" butonu
- **Pencere:** 420px yükseklik, mobilde ekrana sığacak genişlik
- **Durum mesajları:**
  - Key varsa: *"Alışveriş sorularınız için buradayım."*
  - Key yoksa: *"API key eklenince aktif olur (.env.local)."*
- **Dosya:** `Web/src/components/ai/AiAssistant.tsx`
- **Layout'a eklendi:** `Web/src/app/layout.tsx` → `<AiAssistant />`

---

## 4. Teknik Akış

```
Kullanıcı (tarayıcı)
    │
    │  "merhaba" yazar, Gönder'e basar
    ▼
AiAssistant.tsx
    │
    │  POST /api/ai/chat  { "message": "merhaba" }
    ▼
app/api/ai/chat/route.ts  (Next.js Route Handler)
    │
    │  Zod ile mesaj doğrulanır (1–2000 karakter)
    │  GEMINI_API_KEY kontrol edilir
    ▼
lib/ai/gemini.ts
    │
    │  Google Gemini REST API çağrısı
    │  Model: GEMINI_MODEL env (varsayılan: gemini-3.1-flash-lite)
    ▼
Google generativelanguage.googleapis.com
    │
    │  Yanıt metni
    ▼
Tarayıcıda asistan balonu olarak gösterilir
```

### Sistem prompt'u (asistanın kişiliği)

Sunucu her istekte Gemini'ye şu talimatı gönderir (`lib/ai/gemini.ts`):

- VBShop alışveriş asistanısın
- Türkçe, kısa ve net yanıt ver
- Ürün, sepet, sipariş, site kullanımı hakkında yardım et
- Stok/fiyat/sipariş durumunda gerçek veriye erişemediğini söyle
- Kaba veya alakasız istekleri nazikçe reddet

---

## 5. API Endpoint'leri

### `GET /api/ai/status`

Key tanımlı mı kontrol eder (key'in kendisini döndürmez).

**Örnek yanıt:**
```json
{ "configured": true }
```

**Dosya:** `Web/src/app/api/ai/status/route.ts`

---

### `POST /api/ai/chat`

Kullanıcı mesajını Gemini'ye iletir.

**İstek:**
```json
{ "message": "Sepetime nasıl ürün eklerim?" }
```

**Başarılı yanıt (200):**
```json
{ "reply": "Ürün detay sayfasında..." }
```

**Hata yanıtları:**

| HTTP | Durum |
|------|-------|
| 400 | Mesaj boş veya 2000 karakterden uzun |
| 503 | `GEMINI_API_KEY` tanımlı değil |
| 502 | Gemini API hatası (kota, geçersiz key vb.) |

**Dosya:** `Web/src/app/api/ai/chat/route.ts`

---

## 6. Dosya ve Klasör Yapısı

```
Web/
├── .env.example                    ← örnek env (GEMINI_* satırları)
├── .env.local                      ← gerçek key (GIT'E GİTMEZ)
├── src/
│   ├── lib/ai/
│   │   ├── config.ts               ← GEMINI_API_KEY + GEMINI_MODEL okuma
│   │   └── gemini.ts               ← Gemini REST çağrısı + hata mesajları
│   ├── features/ai/
│   │   ├── api/ai-api.ts           ← fetch ile /api/ai/* çağrıları
│   │   ├── queries/use-ai.ts       ← useAiStatus(), useAiChat() hook'ları
│   │   ├── schemas/ai.ts           ← Zod: mesaj validasyonu
│   │   ├── types/ai.ts             ← TypeScript tipleri
│   │   └── README.md               ← kısa teknik özet
│   ├── app/api/ai/
│   │   ├── chat/route.ts           ← POST sohbet
│   │   └── status/route.ts         ← GET durum
│   └── components/ai/
│       └── AiAssistant.tsx         ← sohbet arayüzü (UI)
```

---

## 7. Kurulum — Her Geliştirici İçin

### Adım 1: API key alın

1. [Google AI Studio](https://aistudio.google.com/apikey) adresine gidin
2. Google hesabınızla giriş yapın
3. **Create API key** ile yeni key oluşturun

### Adım 2: `.env.local` dosyasını düzenleyin

```bash
cd Web
cp .env.example .env.local   # henüz yoksa
```

`Web/.env.local` içine ekleyin:

```env
GEMINI_API_KEY=buraya_kendi_keyinizi_yapistirin
GEMINI_MODEL=gemini-3.1-flash-lite
```

> Herkes **kendi key'ini** kullanmalıdır. Key'i WhatsApp, Slack veya GitHub'a **yazmayın**.

### Adım 3: Dev sunucuyu başlatın

```bash
npm run dev:reset
```

veya

```bash
npm run dev
```

Tarayıcı: **http://localhost:3000** → sağ alttaki **AI** butonuna tıklayın.

### Adım 4: Test edin

Terminalden:

```bash
curl http://localhost:3000/api/ai/status

curl -X POST http://localhost:3000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"merhaba"}'
```

---

## 8. Ortam Değişkenleri

| Değişken | Zorunlu | Açıklama |
|----------|---------|----------|
| `GEMINI_API_KEY` | Evet (AI için) | Google AI Studio API key |
| `GEMINI_MODEL` | Hayır | Kullanılacak model; varsayılan `gemini-3.1-flash-lite` |

**Model seçimi** yalnızca `GEMINI_MODEL` env değişkeni üzerinden yapılır. Kod içinde başka yerde model adı **hardcode edilmez**; tek varsayılan `src/lib/ai/config.ts` dosyasındadır.

`.env.example` (GitHub'a gider, key içermez):

```env
GEMINI_API_KEY=
GEMINI_MODEL=gemini-3.1-flash-lite
```

---

## 9. Güvenlik Kuralları

| Yapın | Yapmayın |
|-------|----------|
| Key'i `.env.local`'de tutun | Key'i commit'e eklemeyin |
| Sunucu route'ları üzerinden çağırın | `NEXT_PUBLIC_GEMINI_API_KEY` kullanmayın |
| Her geliştirici kendi key'ini alsın | Key'i ekip sohbetine yapıştırmayın |
| `.gitignore`'da `.env.local` olduğunu doğrulayın | Key'i frontend bundle'a taşımayın |

Tüm Gemini istekleri **sunucuda** (`/api/ai/chat`) yapılır. Tarayıcı Google'a doğrudan istek atmaz.

---

## 10. Sık Karşılaşılan Hatalar

### "GEMINI_API_KEY tanımlı değil"

- `.env.local` dosyasında key yok veya boş
- Dev sunucuyu env değişikliğinden sonra yeniden başlatın: `npm run dev:reset`

### "Gemini API kotası doldu..."

- Google ücretsiz kotanız dolmuş veya seçili model için limit yok
- [Google AI Studio](https://aistudio.google.com/apikey) → yeni key deneyin
- [Kota sayfası](https://ai.dev/rate-limit) → kullanımınızı kontrol edin
- `.env.local` içinde `GEMINI_MODEL` değerini güncelleyin

### "This model ... is no longer available"

- Eski model adı `.env.local`'de kalmış olabilir
- `GEMINI_MODEL=gemini-3.1-flash-lite` yapın ve sunucuyu yeniden başlatın

### Asistan görünüyor ama Gönder pasif

- `GET /api/ai/status` → `{ "configured": false }` dönüyordur
- Key ekleyip sunucuyu yeniden başlatın

---

## 11. Backend / Mobile Ekibi İçin

- **Backend (`API/`) ekibinin yapması gereken bir şey yok.** AI, e-ticaret API'sinden tamamen bağımsızdır.
- **Mobile ekibi** isterse benzer bir asistanı Flutter tarafında ayrıca implemente edebilir; web'deki kod referans alınabilir.
- Production'da AI kullanılacaksa sunucu ortamına `GEMINI_API_KEY` ve `GEMINI_MODEL` env değişkenleri eklenmelidir (Vercel, Docker vb.).

---

## 12. Gelecekte Yapılabilecekler (henüz yok)

- Sohbet geçmişini sunucuda veya localStorage'da saklama
- Ürün arama sonuçlarını AI yanıtına bağlama (gerçek API verisi)
- Rate limiting (kötüye kullanım önleme)
- Streaming yanıt (kelime kelime yazdırma)

---

## 13. Özet Checklist

- [ ] `Web/.env.local` oluşturuldu
- [ ] `GEMINI_API_KEY` eklendi
- [ ] `GEMINI_MODEL=gemini-3.1-flash-lite` ayarlandı
- [ ] `npm run dev` veya `npm run dev:reset` çalıştırıldı
- [ ] http://localhost:3000 → AI butonu test edildi
- [ ] Key GitHub'a commit **edilmedi**

---

*Son güncelleme: Temmuz 2026 — VB10 Staj · VBShop Web AI Asistan*
