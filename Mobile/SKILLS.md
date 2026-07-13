# SKILLS.md — Mobil Takımın Skill'leri (2026 Zorunlu Hedefi)

> Ödevin ortak son aşaması: geliştirme akışındaki tekrarları skill/command/agent'a
> dönüştürmek. Bu dosya mobil takımın ürettiği araçları belgeler.

## 1) `/screen-scaffold` — Yeni Feature/Ekran İskeleti

**Dosya:** [`.claude/skills/screen-scaffold/SKILL.md`](../.claude/skills/screen-scaffold/SKILL.md) (repo kökünde)

**Neden yaptık?**
Proje boyunca aynı işi 8 kez yaptık: yeni bir feature açarken domain entity +
repository sözleşmesi + mock/remote datasource + repository impl + Riverpod
provider + ekran + rota kaydı. Her seferinde AI'a bu katman düzenini, isimlendirme
kurallarını ve "boş/yükleniyor/hata durumu zorunlu" kuralını baştan anlatıyorduk.
Skill bu talimatı tek seferde standartlaştırdı.

**Nasıl çağrılır?**
Claude Code içinde:

```
/screen-scaffold kampanyalar ekranı: kampanya listesi + detay, mock veriyle
```

**Örnek çıktı (özet):**

```
features/campaigns/
├── domain/entities/campaign.dart            # Equatable entity
├── domain/repositories/campaigns_repository.dart
├── data/models/campaign_model.dart          # @JsonSerializable (+ .g.dart)
├── data/datasources/campaigns_mock_data_source.dart
├── data/repositories/campaigns_repository_impl.dart
└── presentation/
    ├── providers/campaigns_providers.dart   # FutureProvider + controller
    └── screens/campaigns_screen.dart        # when(data/loading/error) + EmptyState
+ core/router/app_router.dart                # '/campaigns' rotası eklendi
```

**Neden işe yaradı?**
- Katman atlamayı (ekrandan doğrudan datasource çağırmak gibi) engelliyor.
- Boş/yükleniyor/hata durumları unutulmuyor — ödev değerlendirme kriteri.
- Yeni ekran maliyeti ~1 saat elle iskeletlemeden ~5 dakikalık gözden geçirmeye düştü.
- Takıma yeni katılan biri, skill'i okuyarak projenin mimari sözleşmesini öğreniyor.

## Fikir Havuzu (sıradaki adaylar)

- `/api-swap` — Backend sözleşmesi yayınlanınca bir feature'ın remote
  datasource'unu OpenAPI şemasından üretmek.
- `/maestro-flow` — QA için kritik akışlardan Maestro E2E flow taslağı çıkarmak
  (QA takımıyla ortak).
- `/seed-product` — Yeni seed ürün/kategori JSON'u üretip modele uygunluğunu
  doğrulamak.
