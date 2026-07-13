# API Gaps

PDF sözleşmesi (`ecommerce_api_contract_v1_detailed.pdf`) yeniden doğrulandı. Aşağıdaki özellikler **sözleşmede yoktur**; frontend bu nedenle gerçek backend endpoint’i uydurmaz.

## 1. Favoriler

**Durum:** PDF’de favori ekleme/çıkarma/listeleme endpoint’i **yok**.

**Frontend stratejisi:**
- `FavoritesRepository` soyut arayüzü tanımlanır.
- Yalnızca `development` ortamında `localStorage` tabanlı `LocalFavoritesRepository` kullanılır.
- Production’da favori UI gösterilir ancak kalıcılık backend gelene kadar dev-only fallback ile sınırlıdır; README’de açıkça belirtilir.

## 2. Kategori listeleme endpoint’i

**Durum:** Ayrı `GET /categories` endpoint’i **yok**.

**Frontend stratejisi:**
- Ürün listesi cevaplarındaki `category: { id, name }` alanlarından türetilmiş filtre seçenekleri kullanılır.
- Bu yöntem **tüm kategorileri garanti etmez** (yalnızca listelenen/önbellekteki ürünlerden türetilir).
- Kategori filtresi `categoryId` query parametresi ile API’ye iletilir (PDF’de tanımlı).

## 3. Sepetten ürün silme

**Durum:** `DELETE /cart/items/{productId}` veya eşdeğeri **yok**. Yalnızca:
- `POST /cart/items` (ekle/artır)
- `PUT /cart/items/{productId}` (miktar set)

**Frontend stratejisi:**
- `quantity=0` varsayımı **yapılmaz**.
- Silme butonu production’da **devre dışı** veya açıklayıcı mesajla gizlenir.
- Development ortamında izole fallback: kullanıcıya “API sözleşmesinde silme yok” uyarısı gösterilir; var olmayan DELETE çağrısı **yapılmaz**.

## 4. Ürün yorumları

**Durum:** Mobil taslakta `/products/{id}/reviews` vardı; **PDF sözleşmesinde yok**.

**Frontend stratejisi:** Yorum UI’si implement edilmez.

## 5. Admin paneli

**Durum:** PDF’de admin endpoint’leri **yok**.

**Frontend stratejisi:** Admin sayfaları kapsam dışı.

## 6. E-posta resend (profil) request body

**Durum:** `POST /users/me/email/resend` için PDF request body örneği eksik; yalnızca response gösterilmiş.

**Frontend stratejisi:** Boş body veya backend ekibinin netleştirmesini bekleyen minimal çağrı; hata durumunda kullanıcıya genel mesaj.
