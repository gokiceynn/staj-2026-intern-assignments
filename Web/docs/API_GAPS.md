# API Gaps

Eski PDF sözleşmesi (`ecommerce_api_contract_v1_detailed.pdf`) ile güncel [`ecommerce_api_contract_v1.3.md`](../../Docs/ecommerce_api_contract_v1.3.md) karşılaştırılmıştır.

PDF'de eksik olan aşağıdaki maddeler güncel v1.3 sözleşmesinde tamamlanmıştır. Ayrıca **§2.0 Netleştirilmiş kararlar** bölümünde kayıt ve hesap path'leri kesinleştirilmiştir (`POST /auth/customer/register`; `POST /auth/register` kullanılmaz).

| Konu | Güncel durum | Endpointler / karar |
|---|---|---|
| Favoriler | Tamamlandı | `GET /favorites`, `POST /favorites/{productId}`, `DELETE /favorites/{productId}` |
| Kategoriler | Tamamlandı | `GET /categories`; kategoriler recursive `children` ağacı ve `parentCategoryId` ile döner |
| Sepetten ürün silme | Tamamlandı | `DELETE /cart/items/{productId}` |
| Ürün yorumları | Tamamlandı | Yorum listeleme, ekleme, güncelleme ve silme endpointleri eklendi |
| Admin paneli | Tamamlandı | Dashboard ve salt okunur kullanıcı/satıcı/sipariş endpointleri; kargo firması CRUD |
| Profil e-posta resend body | Netleştirildi | `POST /account/me/email/resend` request body: `{ "password": "..." }` |

## Ürün yorum endpointleri

- `GET /products/{id}/reviews`
- `POST /products/{id}/reviews`
- `PUT /products/{productId}/reviews/{reviewId}`
- `DELETE /products/{productId}/reviews/{reviewId}`

## Sonuç

Bu listedeki açık maddelerin tamamı güncel v1.3 API sözleşmesinde karşılanmıştır.
