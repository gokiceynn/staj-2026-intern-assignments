# SKILLS.md — Web Takımının Skill'leri (2026 Son Aşama)

> Geliştirme akışındaki tekrarları skill/command/agent'a dönüştürme.
> Bu dosya **yalnızca Web/** tarafını belgeler. **Mobile/ bu kapsamda değildir.**

---

## 1) `/home-section` — Ana Sayfa Ürün Bölümü

**Dosya:** [`.claude/skills/home-section/SKILL.md`](.claude/skills/home-section/SKILL.md)

### Neden yaptık?

Proje boyunca ana sayfaya aynı işi defalarca yaptık:

- `SectionHeader` (başlık + "Tümünü Gör")
- `ProductRail` (mobil yatay ray) veya `FeaturedProducts` (masaüstü grid)
- `page.tsx`'te `fetchPublic` + `normalizePaginated` + `withPhotoUrls`
- Boş liste guard'ı, API yoksa empty state

Her seferinde AI'a bu kalıbı, dosya yollarını ve "Mobile'a dokunma" kuralını baştan anlatıyorduk.

### Nasıl çağrılır?

Cursor / Claude Code içinde:

```
/home-section
Başlık: "En Yeni Ürünler"
sortBy: newest
Mobil ve masaüstü ana sayfaya ekle.
```

### Örnek çıktı (özet)

```
Web/src/app/page.tsx
  + productListPath({ page: 1, size: 8, sortBy: "newest" })
  + HomeMobileSections'a yeni prop

Web/src/components/home/HomeMobileSections.tsx
  + SectionHeader title="En Yeni Ürünler" href="/products?sortBy=newest"
  + ProductRail products={newest}

Web/src/app/page.tsx (md:block)
  + FeaturedProducts title="En Yeni Ürünler" ...
```

### Neden işe yaradı?

- Katman ve dosya yolu karışıklığı azaldı (`HomeMobileSections` vs `FeaturedProducts`).
- API zarfı (`normalizePaginated`) ve foto URL (`withPhotoUrls`) unutulmuyor.
- Mobil ray için `ProductCard variant="rail"` kuralı skill içinde sabit.
- Yeni bölüm maliyeti ~30–45 dk manuel anlatımdan ~10 dk gözden geçirmeye indi.
- **Mobile/ hiç değişmiyor** — web ekibi kendi sınırlarında kalıyor.

### Demo (30 sn)

1. "Ana sayfaya En Yeni Ürünler bölümü ekle" de.
2. Skill'in ürettiği diff'i göster: `page.tsx` + `HomeMobileSections.tsx`.
3. `localhost:3000`'de mobil ve masaüstü görünümü kontrol et.

---

## Fikir havuzu (henüz yapılmadı)

| Skill | Amaç |
|-------|------|
| `/campaign-modal` | Karşılama modalı + köşe SVG dekorasyon kuralları |
| `/promo-carousel` | HeroPromo tarzı tam genişlik banner carousel |
| `/dev-reset` | `.next` cache temizle + `npm run dev:reset` checklist |

---

## Değerlendirme özeti

| Kriter | `/home-section` |
|--------|-----------------|
| Gerçek görevde kullanıldı mı? | Ana sayfa bölümleri (Süper Fırsatlar, Öne Çıkanlar vb.) |
| Zaman kazandırdı mı? | Evet — tekrarlayan anlatım kalktı |
| Tekrar kullanılabilir mi? | Evet — her yeni ana sayfa rayı için |
| Projeyi bozar mı? | Hayır — yalnızca talimat dosyası; uygulama isteğe bağlı |
