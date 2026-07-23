# VBShop Karşılama Kampanya Modalı — Ekip Bilgilendirme Notu

Bu belge, web uygulamasına eklenen **giriş yapmamış kullanıcılara gösterilen kampanya modalının** proje arkadaşları tarafından anlaşılması ve olası sorunlarda ne yapılacağının açıklanması için hazırlanmıştır.

**Konum:** `Web/` klasörü  
**Backend bağımlılığı:** Yok — modal yalnızca oturum durumuna bakar

---

## 1. Bu Özellik Ne Yapar?

Siteye **giriş yapmamış** kullanıcılar ana sayfayı açtığında tam ekran bir kampanya modalı görür:

- Ortada `anaekran.png` kampanya görseli
- Dört köşede yaprak dekorasyonları (`solust`, `sagust`, `solalt`, `sagalt` SVG)
- Yapraklarda hafif rüzgar sallanma animasyonu
- Görseldeki **"HEMEN KAYIT OL"** alanına tıklanınca `/register` sayfasına gider
- Sağ üstteki **×** veya **Escape** ile kapatılır

Giriş yapmış kullanıcıya modal **gösterilmez**.

---

## 2. Dosya Yapısı

| Dosya / klasör | Açıklama |
|----------------|----------|
| `Web/public/anaekran.png` | Ana kampanya görseli |
| `Web/public/solust.svg` | Sol üst yaprak |
| `Web/public/sagust.svg` | Sağ üst yaprak |
| `Web/public/solalt.svg` | Sol alt yaprak |
| `Web/public/sagalt.svg` | Sağ alt yaprak |
| `Web/src/components/campaign/WelcomeCampaignModal.tsx` | Modal bileşeni |
| `Web/src/components/campaign/__tests__/WelcomeCampaignModal.test.tsx` | Birim testleri |
| `Web/src/app/globals.css` | Yaprak sallanma animasyonları (`leaf-sway`) |
| `Web/src/app/layout.tsx` | `<WelcomeCampaignModal />` burada render edilir |

---

## 3. Neden Her Bilgisayarda Aynı Görünür?

Modal, piksel yerine **tuval oranına göre yüzde konumlandırma** kullanır:

- Ana görsel tuvali: **1448 × 1086** (sabit `aspect-ratio`)
- Yapraklar ve kayıt butonu bu tuvale göre `%` ile hizalanır
- Ekran büyüdükçe her şey **orantılı** büyür; birbirine göre kaymaz
- Farklı ekran genişlikleri için ayrı `sm:` / `md:` boyutları **kullanılmaz**

Bu sayede laptop, monitör veya dar tarayıcı penceresinde düzen aynı kalır.

---

## 4. Projeyi İlk Kez Çeken Arkadaşlar İçin Kurulum

PowerShell veya terminal:

```powershell
git pull
cd Web
npm install
npm run dev
```

Tarayıcı: `http://localhost:3000`

Modalı görmek için **çıkış yapmış** olmanız gerekir (giriş yapmamış ziyaretçi gibi).

---

## 5. Sık Karşılaşılan Sorunlar ve Çözümler

### Modal hiç görünmüyor

| Olası neden | Ne yapmalı? |
|-------------|-------------|
| Giriş yapmışsınızdır | Çıkış yapın veya gizli pencerede deneyin |
| Auth API yanıt vermiyor | `isPending` bitene kadar bekleyin; backend kapalıysa bile modal açılmalı |
| Eski kod | `git pull` yapın, `npm run dev` yeniden başlatın |

### Görseller yok / kırık ikon

| Olası neden | Ne yapmalı? |
|-------------|-------------|
| `Web/public/` dosyaları eksik | `git pull` sonrası şu dosyaların olduğunu kontrol edin: `anaekran.png`, dört SVG |
| Eski önbellek | **Ctrl + Shift + R** (Mac: **Cmd + Shift + R**) ile sert yenileme |

### Yapraklar veya buton kaymış görünüyor

| Olası neden | Ne yapmalı? |
|-------------|-------------|
| Eski branch | `feat/web-gemini-ai` veya güncel branch'i çektiğinizden emin olun |
| Yerel CSS değişikliği | `git status` ile kontrol edin; istemeden değiştirdiyseniz geri alın |
| Konum ayarı | `WelcomeCampaignModal.tsx` içindeki `LEAF_DECORATIONS` sabitlerini düzenleyin |

### `Image has both "width" and "fill"` hatası

Next.js `Image` bileşeninde `fill` kullanıldığında `width` / `height` **verilmemeli**. Güncel kodda bu düzeltildi. Hata alıyorsanız `git pull` yapın.

### Webpack / `__webpack_modules__` hatası

```powershell
cd Web
npm run dev:reset
```

Ardından tarayıcıda sert yenileme yapın.

### Animasyon çok hızlı / yavaş / rahatsız edici

Animasyonlar `Web/src/app/globals.css` içindeki `leaf-sway` sınıflarında tanımlıdır.  
Sistem **hareket azaltma** (`prefers-reduced-motion`) açıksa animasyon otomatik kapanır.

---

## 6. Testleri Çalıştırma

```powershell
cd Web
npm test -- src/components/campaign/__tests__/WelcomeCampaignModal.test.tsx
```

7 test geçmelidir (giriş durumu, kapatma, kayıt linki, Escape tuşu vb.).

---

## 7. Konum Ayarını Değiştirmek

Tüm yaprak konumları tek yerde:

`Web/src/components/campaign/WelcomeCampaignModal.tsx` → `LEAF_DECORATIONS`

Örnek alanlar:

- `left`, `top`, `right`, `bottom` — köşe offset (yüzde)
- `widthPercent` — yaprak genişliği (tuvale göre yüzde)

Kayıt butonu tıklama alanı: `REGISTER_HOTSPOT` sabiti.

Değişiklikten sonra sayfayı yenileyin; farklı ekranlarda da aynı oranları koruyun (piksel yerine `%` kullanın).

---

## 8. Özet Kontrol Listesi

- [ ] `git pull` yaptım
- [ ] `Web/public/` altında 5 görsel dosyası var
- [ ] `cd Web && npm install && npm run dev`
- [ ] Çıkış yapmış / giriş yapmamış kullanıcı olarak test ettim
- [ ] Sorun devam ederse sert yenileme ve `npm run dev:reset` denedim

Sorun çözülmezse ekip içinde **hangi branch**, **hangi tarayıcı** ve **ekran görüntüsü** ile birlikte yazın.
