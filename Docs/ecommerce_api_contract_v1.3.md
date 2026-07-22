# E-Ticaret API Sözleşmesi

> **Sürüm:** v1.3  
> **Base URL:** `/api/v1`  
> **Hedef:** Web ve mobil frontend ekipleri  
> **Son güncelleme:** 2026-07-15

Bu doküman frontend ve mobil ekiplerinin backend'i beklemeden aynı API sözleşmesine göre geliştirme yapabilmesi için hazırlanmıştır. Her endpoint ayrı ayrı ele alınmış; request ve response örnekleri JSON olarak verilmiştir.

Bu sözleşmede request ve response DTO'ları doğrudan JSON alan yapılarıyla tanımlanır; herhangi bir programlama diline ait model tanımı kullanılmaz.

Roller:

- `Customer`: katalog, favori, sepet, checkout, profil ve kendi siparişleri
- `Seller`: kendi mağazası, ürünleri, sipariş paketleri ve kargo işlemleri
- `Admin`: dashboard, kullanıcı/satıcı/sipariş görüntüleme ve kargo firması yönetimi

---

## 1. Global API Standartları

### 1.1. Yetkilendirme

Yanında **Korumalı**, **Customer**, **Seller** veya **Admin** yazan endpointlerde aşağıdaki header zorunludur:

```http
Authorization: Bearer <access_token>
```

Hesap rolü hem JWT içindeki `role` claim'inde hem de login/doğrulama response'undaki `data.account.role` alanında bulunur. Frontend yönlendirme için response alanını kullanabilir; endpoint yetkilendirmesi JWT claim'iyle yapılır.

---

### 1.2. Başarılı yanıt zarfı

`GET /photos/{id}` dışındaki tüm endpointler aynı global zarfı döner.

```json
{
  "data": {
    "id": "u_123",
    "email": "ornek@example.com"
  },
  "isSuccess": true,
  "message": "İşlem başarıyla tamamlandı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:00:00.000Z"
}
```

| Alan | Tip | Açıklama |
|---|---|---|
| `data` | object, array veya null | Endpointin döndürdüğü veri |
| `isSuccess` | boolean | İşlem başarılıysa `true` |
| `message` | string | Kullanıcıya gösterilebilecek mesaj |
| `code` | integer | HTTP durum kodu |
| `errors` | object veya null | Alan bazlı validasyon/iş kuralı hataları |
| `timestamp` | string | ISO-8601 UTC tarih |

### 1.3. Hata yanıt zarfı

```json
{
  "data": null,
  "isSuccess": false,
  "message": "Gönderilen form verilerinde hatalar bulunuyor.",
  "code": 400,
  "errors": {
    "price": ["Fiyat 0'dan büyük olmalıdır."],
    "passwordConfirm": ["Şifreler birbiriyle eşleşmiyor."]
  },
  "timestamp": "2026-07-15T10:00:00.000Z"
}
```

| HTTP | Anlamı |
|---|---|
| `200` | İşlem başarılı |
| `201` | Kaynak oluşturuldu |
| `400` | Request veya alan validasyonu hatalı |
| `401` | Token yok, geçersiz veya süresi dolmuş |
| `403` | Rol yetkisi yetersiz |
| `404` | Kaynak bulunamadı |
| `409` | Stok veya durum geçişi çakışması |
| `422` | Ödeme gibi bir iş kuralı başarısız |

### 1.4. Sayfalama formatı

Sayfalı liste endpointlerinin `data` alanı aşağıdaki formattadır:

```json
{
  "items": [],
  "pageIndex": 1,
  "pageSize": 10,
  "totalCount": 0,
  "totalPages": 0
}
```

Varsayılan değerler `page=1`, `size=10`; maksimum `size=100`'dür.

### 1.5. Ortak veri kuralları

- JSON alan adları `camelCase` kullanır.
- Tüm ID alanları string'dir.
- Tarihler ISO-8601 UTC formatındadır.
- Para birimi `TRY`'dir.
- Para alanları iki ondalıklı sayı olarak gönderilir.
- Request body'si olmayan endpointlerde body gönderilmez.

### 1.6. Durum etiketi ve ikon metadata'sını getirme

`GET /metadata/statuses` · **Anonim**

Sipariş, paket, kargo ve ödeme durumlarının kullanıcıya gösterilecek etiket ve ikonlarını döner. Sipariş response'larındaki `status` alanları string kalır; frontend bu kodu metadata ile eşleştirir.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "orderStatuses": [
      {
        "code": "Paid",
        "label": "Ödendi",
        "iconId": "img_status_order_paid",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_paid"
      },
      {
        "code": "Preparing",
        "label": "Hazırlanıyor",
        "iconId": "img_status_order_preparing",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_preparing"
      },
      {
        "code": "PartiallyShipped",
        "label": "Kısmen Kargolandı",
        "iconId": "img_status_order_partially_shipped",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_partially_shipped"
      },
      {
        "code": "Shipped",
        "label": "Kargolandı",
        "iconId": "img_status_order_shipped",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_shipped"
      },
      {
        "code": "PartiallyDelivered",
        "label": "Kısmen Teslim Edildi",
        "iconId": "img_status_order_partially_delivered",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_partially_delivered"
      },
      {
        "code": "Delivered",
        "label": "Teslim Edildi",
        "iconId": "img_status_order_delivered",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_delivered"
      },
      {
        "code": "PartiallyCancelled",
        "label": "Kısmen İptal Edildi",
        "iconId": "img_status_order_partially_cancelled",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_partially_cancelled"
      },
      {
        "code": "Cancelled",
        "label": "İptal Edildi",
        "iconId": "img_status_order_cancelled",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_order_cancelled"
      }
    ],
    "packageStatuses": [
      {
        "code": "Paid",
        "label": "Ödendi",
        "iconId": "img_status_package_paid",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_package_paid"
      },
      {
        "code": "Preparing",
        "label": "Hazırlanıyor",
        "iconId": "img_status_package_preparing",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_package_preparing"
      },
      {
        "code": "Shipped",
        "label": "Kargolandı",
        "iconId": "img_status_package_shipped",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_package_shipped"
      },
      {
        "code": "Delivered",
        "label": "Teslim Edildi",
        "iconId": "img_status_package_delivered",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_package_delivered"
      },
      {
        "code": "Cancelled",
        "label": "İptal Edildi",
        "iconId": "img_status_package_cancelled",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_package_cancelled"
      }
    ],
    "shipmentStatuses": [
      {
        "code": "NotCreated",
        "label": "Kargo Kaydı Oluşmadı",
        "iconId": "img_status_shipment_not_created",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_shipment_not_created"
      },
      {
        "code": "LabelCreated",
        "label": "Kargo Etiketi Oluşturuldu",
        "iconId": "img_status_shipment_label_created",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_shipment_label_created"
      },
      {
        "code": "InTransit",
        "label": "Yolda",
        "iconId": "img_status_shipment_in_transit",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_shipment_in_transit"
      },
      {
        "code": "Delivered",
        "label": "Teslim Edildi",
        "iconId": "img_status_shipment_delivered",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_shipment_delivered"
      },
      {
        "code": "Cancelled",
        "label": "İptal Edildi",
        "iconId": "img_status_shipment_cancelled",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_shipment_cancelled"
      }
    ],
    "paymentStatuses": [
      {
        "code": "Success",
        "label": "Ödeme Başarılı",
        "iconId": "img_status_payment_success",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_payment_success"
      },
      {
        "code": "Failed",
        "label": "Ödeme Başarısız",
        "iconId": "img_status_payment_failed",
        "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_status_payment_failed"
      }
    ]
  },
  "isSuccess": true,
  "message": "Durum metadata bilgileri getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T09:55:00.000Z"
}
```

Frontend bu endpointi uygulama açılışında bir kez çağır ve sonucu cache'ler. Bilinmeyen bir durum kodunda genel fallback ikon ve ham `status` metni kullanılır.

---

## 2. Auth Endpointleri

### 2.0. Netleştirilmiş kararlar (v1.3)

Aşağıdaki tablolar, önceki taslaklardaki çelişkileri giderir. **Backend ve tüm frontend ekipleri yalnızca bu kararları uygular.**

#### Kayıt endpoint kararı

| Konu | Karar |
|---|---|
| Müşteri kaydı | **Tek resmi yol:** `POST /auth/customer/register` |
| Satıcı kaydı | `POST /auth/seller/register` |
| `POST /auth/register` | **Kullanılmaz ve tanımlı değildir.** Eski kısa yol kaldırılmıştır. |
| Gerekçe | Çok rollü mimaride rol ayrımı açık olmalıdır; satıcı kaydı ile simetrik path kullanımı (`/auth/{role}/register`) tercih edilir. |

#### Hesap ve müşteri namespace kararı

| Konu | Karar |
|---|---|
| Profil okuma / güncelleme / şifre / e-posta | `GET/PUT /account/me`, `PUT /account/me/password`, `PUT /account/me/email` vb. (Customer, Seller, Admin) |
| Müşteri hesabını silme | `DELETE /customer/me` (yalnızca Customer) |
| `GET /customer/me` | **Tanımlı değildir.** Profil bilgisi için `GET /account/me` kullanılır. |
| Müşteri adresleri | `GET/POST/PUT/DELETE /customer/me/addresses` |

---

### 2.1. Müşteri kaydı

`POST /auth/customer/register` · **Anonim**

Yeni bir `Customer` hesabı oluşturur. Kayıt sonrası token verilmez; e-posta doğrulama adımına geçilir.

Request Body:

```json
{
  "email": "rojhat.cetin@example.com",
  "password": "SecurePassword123",
  "passwordConfirm": "SecurePassword123",
  "firstName": "Rojhat",
  "lastName": "Çetin",
  "phoneNumber": "+905554443322"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "sessionId": "sess_customer_9a8b7c",
    "expiresAt": "2026-07-15T10:05:00.000Z"
  },
  "isSuccess": true,
  "message": "Kullanıcı kaydı alındı. E-posta adresinize gelen kodu giriniz.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:00:00.000Z"
}
```

### 2.2. Satıcı kaydı

`POST /auth/seller/register` · **Anonim**

Yeni bir `Seller` hesabı ve mağaza profili oluşturur. Kayıt e-posta koduyla doğrulanır.

Request Body:

```json
{
  "email": "magaza@example.com",
  "password": "SecurePassword123",
  "passwordConfirm": "SecurePassword123",
  "firstName": "Ayşe",
  "lastName": "Yılmaz",
  "phoneNumber": "+905551234567",
  "storeName": "Tekno Dükkan",
  "taxNumber": "1234567890",
  "taxOffice": "Avcılar"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "sessionId": "sess_seller_7b6c5d",
    "expiresAt": "2026-07-15T10:05:00.000Z"
  },
  "isSuccess": true,
  "message": "Satıcı kaydı alındı. E-posta adresinize gelen kodu giriniz.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:00:00.000Z"
}
```

### 2.3. Giriş

`POST /auth/login` · **Anonim**

Customer, Seller ve Admin aynı endpointten giriş yapar. Her rol için aynı ortak `account` alan yapısı döner; yönlendirme `account.role` değerine göre yapılır.

Request Body:

```json
{
  "email": "rojhat.cetin@example.com",
  "password": "SecurePassword123"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "accessTokenExpiresAt": "2026-07-15T10:15:00.000Z",
    "refreshToken": "7c4a1b83-82ef-4b47-97d8-8d21b3a51f8a",
    "refreshTokenExpiresAt": "2026-07-29T10:00:00.000Z",
    "account": {
      "id": "u_98124712",
      "email": "rojhat.cetin@example.com",
      "firstName": "Rojhat",
      "lastName": "Çetin",
      "phoneNumber": "+905554443322",
      "role": "Customer",
      "createdAt": "2026-03-15T12:00:00.000Z"
    }
  },
  "isSuccess": true,
  "message": "Giriş başarılı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:00:00.000Z"
}
```

`account` yalnızca ortak kimlik bilgilerini taşır; Customer adresleri, Seller mağaza bilgileri veya Admin dashboard verileri login response'una eklenmez. Login sonrası rol bazlı ilk istek:

- `Customer` → `GET /account/me`
- `Seller` → `GET /account/me`, ardından `GET /seller/profile`
- `Admin` → `GET /account/me`, ardından `GET /admin/dashboard`

### 2.4. Çıkış

`POST /auth/logout` · **Korumalı**

Aktif oturumu sonlandırır.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Başarıyla çıkış yapıldı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:10:00.000Z"
}
```

### 2.5. Token yenileme

`POST /auth/refresh-token` · **Kısmi korumalı**

Süresi dolmuş access token header'da, refresh token body'de gönderilir.

Headers:

```http
Authorization: Bearer <expired_access_token>
```

Request Body:

```json
{
  "refreshToken": "7c4a1b83-82ef-4b47-97d8-8d21b3a51f8a"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.new...",
    "accessTokenExpiresAt": "2026-07-15T10:30:00.000Z",
    "refreshToken": "9a2b8c34-71df-4e12-ac56-1e11a2f43d2c",
    "refreshTokenExpiresAt": "2026-07-29T10:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Token başarıyla yenilendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:15:00.000Z"
}
```

### 2.6. E-posta kodunu doğrulama

`POST /auth/email/verify` · **Anonim**

Müşteri veya satıcı kaydından sonra OTP kodunu doğrular ve oturum açar.

Request Body:

```json
{
  "sessionId": "sess_customer_9a8b7c",
  "code": "845213"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "accessTokenExpiresAt": "2026-07-15T10:20:00.000Z",
    "refreshToken": "7c4a1b83-82ef-4b47-97d8-8d21b3a51f8a",
    "refreshTokenExpiresAt": "2026-07-29T10:05:00.000Z",
    "account": {
      "id": "u_98124712",
      "email": "rojhat.cetin@example.com",
      "firstName": "Rojhat",
      "lastName": "Çetin",
      "phoneNumber": "+905554443322",
      "role": "Customer",
      "createdAt": "2026-07-15T10:00:00.000Z"
    }
  },
  "isSuccess": true,
  "message": "Hesap doğrulandı ve oturum açıldı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:05:00.000Z"
}
```

### 2.7. E-posta kodunu tekrar gönderme

`POST /auth/email/resend` · **Anonim**

Request Body:

```json
{
  "email": "rojhat.cetin@example.com"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "sessionId": "sess_customer_new_123",
    "expiresAt": "2026-07-15T10:11:00.000Z"
  },
  "isSuccess": true,
  "message": "Yeni doğrulama kodu gönderildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:06:00.000Z"
}
```

### 2.8. Şifremi unuttum

`POST /auth/forgot-password` · **Anonim**

Request Body:

```json
{
  "email": "rojhat.cetin@example.com"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "sessionId": "sess_password_a1b2c3",
    "expiresAt": "2026-07-15T10:15:00.000Z"
  },
  "isSuccess": true,
  "message": "Hesap mevcutsa sıfırlama kodu gönderildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:10:00.000Z"
}
```

### 2.9. Şifreyi sıfırlama

`POST /auth/reset-password` · **Anonim**

Request Body:

```json
{
  "sessionId": "sess_password_a1b2c3",
  "code": "294715",
  "newPassword": "NewSecurePassword456",
  "newPasswordConfirm": "NewSecurePassword456"
}
```

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Şifreniz başarıyla güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:15:00.000Z"
}
```

---

## 3. Ortak Hesap ve Müşteri Adres Endpointleri

Kişisel hesap bilgileri rol bağımsız olarak ortak `/account/me/*` endpointlerinden yönetilir. Customer, Seller ve Admin bu endpointlerle kendi kişisel profilini görebilir; ad, telefon, şifre ve e-posta bilgilerini güncelleyebilir.

- Ortak kişisel hesap işlemleri: `/account/me/*`
- Customer adres ve hesap silme işlemleri: `/customer/me/*`
- Seller mağaza profili: `/seller/profile`
- Admin ekranları: `/admin/*`

`/account` ortak kimliği, `/customer` alışveriş müşterisini, `/seller` mağazayı ve `/admin` yönetim alanını ifade eder. Rol namespace'leri tekildir. `products`, `orders` ve `addresses` gibi koleksiyon endpointleri birden fazla kaynak döndürdüğü için çoğul kalır.

Seller kişisel hesabı için `/account/me`, mağaza bilgileri için `/seller/profile` kullanır. Admin kişisel hesabını `/account/me` ile, yönetim ekranlarını `/admin/*` ile kullanır. Hesap silme endpointi güvenlik ve iş akışı nedeniyle yalnızca Customer'a açıktır.

### 3.1. Kişisel hesap bilgilerini getirme

`GET /account/me` · **Customer / Seller / Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "u_98124712",
    "email": "rojhat.cetin@example.com",
    "firstName": "Rojhat",
    "lastName": "Çetin",
    "phoneNumber": "+905554443322",
    "role": "Customer",
    "createdAt": "2026-03-15T12:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Hesap bilgileri getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:20:00.000Z"
}
```

### 3.2. Kişisel hesap bilgilerini güncelleme

`PUT /account/me` · **Customer / Seller / Admin**

E-posta ve şifre dışındaki ortak hesap alanlarını günceller.

Request Body:

```json
{
  "firstName": "Rojhat",
  "lastName": "Çetin",
  "phoneNumber": "+905554443322"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "u_98124712",
    "email": "rojhat.cetin@example.com",
    "firstName": "Rojhat",
    "lastName": "Çetin",
    "phoneNumber": "+905554443322",
    "role": "Customer",
    "createdAt": "2026-03-15T12:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Hesap bilgileri güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:21:00.000Z"
}
```

### 3.3. Şifre değiştirme

`PUT /account/me/password` · **Customer / Seller / Admin**

Request Body:

```json
{
  "currentPassword": "SecurePassword123",
  "newPassword": "NewSecurePassword456",
  "newPasswordConfirm": "NewSecurePassword456"
}
```

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Şifre başarıyla güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:22:00.000Z"
}
```

### 3.4. E-posta değişikliğini başlatma

`PUT /account/me/email` · **Customer / Seller / Admin**

Request Body:

```json
{
  "newEmail": "yeni.adres@example.com",
  "password": "SecurePassword123"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "sessionId": "sess_email_987654",
    "expiresAt": "2026-07-15T10:28:00.000Z"
  },
  "isSuccess": true,
  "message": "Yeni e-posta adresine doğrulama kodu gönderildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:23:00.000Z"
}
```

### 3.5. Yeni e-posta adresini doğrulama

`POST /account/me/email/verify` · **Customer / Seller / Admin**

Request Body:

```json
{
  "sessionId": "sess_email_987654",
  "code": "845213"
}
```

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "E-posta adresi başarıyla güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:24:00.000Z"
}
```

### 3.6. Yeni e-posta kodunu tekrar gönderme

`POST /account/me/email/resend` · **Customer / Seller / Admin**

Request Body:

```json
{
  "password": "SecurePassword123"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "sessionId": "sess_email_new_123",
    "expiresAt": "2026-07-15T10:30:00.000Z"
  },
  "isSuccess": true,
  "message": "Yeni doğrulama kodu gönderildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:25:00.000Z"
}
```

### 3.7. Müşteri hesabını silme

`DELETE /customer/me` · **Customer**

Request Body:

```json
{
  "password": "SecurePassword123"
}
```

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Hesabınız başarıyla silindi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:26:00.000Z"
}
```

### 3.8. Adresleri listeleme

`GET /customer/me/addresses` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": [
    {
      "id": "adr_112233",
      "title": "Ev Adresim",
      "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:7",
      "city": "İstanbul",
      "district": "Avcılar",
      "zipCode": "34320",
      "phoneNumber": "+905551112233"
    }
  ],
  "isSuccess": true,
  "message": "Adres listesi getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:27:00.000Z"
}
```

### 3.9. Adres detayını getirme

`GET /customer/me/addresses/{id}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "adr_112233",
    "title": "Ev Adresim",
    "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:7",
    "city": "İstanbul",
    "district": "Avcılar",
    "zipCode": "34320",
    "phoneNumber": "+905551112233"
  },
  "isSuccess": true,
  "message": "Adres detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:28:00.000Z"
}
```

### 3.10. Adres ekleme

`POST /customer/me/addresses` · **Customer**

Request Body:

```json
{
  "title": "İş Adresi",
  "addressLine": "Plazalar Cad. No:12 Kat:4",
  "city": "İstanbul",
  "district": "Levent",
  "zipCode": "34330",
  "phoneNumber": "+905559998877"
}
```

Response Body (`201 Created`):

```json
{
  "data": {
    "id": "adr_445566",
    "title": "İş Adresi",
    "addressLine": "Plazalar Cad. No:12 Kat:4",
    "city": "İstanbul",
    "district": "Levent",
    "zipCode": "34330",
    "phoneNumber": "+905559998877"
  },
  "isSuccess": true,
  "message": "Adres başarıyla eklendi.",
  "code": 201,
  "errors": null,
  "timestamp": "2026-07-15T10:29:00.000Z"
}
```

### 3.11. Adres güncelleme

`PUT /customer/me/addresses/{id}` · **Customer**

Request Body:

```json
{
  "title": "Ev Adresim (Yeni)",
  "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:9 Daire:2",
  "city": "İstanbul",
  "district": "Avcılar",
  "zipCode": "34320",
  "phoneNumber": "+905551112233"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "adr_112233",
    "title": "Ev Adresim (Yeni)",
    "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:9 Daire:2",
    "city": "İstanbul",
    "district": "Avcılar",
    "zipCode": "34320",
    "phoneNumber": "+905551112233"
  },
  "isSuccess": true,
  "message": "Adres başarıyla güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:30:00.000Z"
}
```

### 3.12. Adres silme

`DELETE /customer/me/addresses/{id}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Adres başarıyla silindi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:31:00.000Z"
}
```

---

## 4. Fotoğraf Endpointleri

### 4.1. Fotoğraf yükleme

`POST /photos` · **Korumalı**

Mağaza logosu, ürün veya yorum için fotoğraf yükler. Normal müşteri profilinde fotoğraf alanı bulunmaz.

Request (`multipart/form-data`):

```text
file: review-product.jpg
```

Response Body (`201 Created`):

```json
{
  "data": {
    "photoId": "img_998877",
    "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_998877",
    "uploadedAt": "2026-07-15T10:32:00.000Z"
  },
  "isSuccess": true,
  "message": "Fotoğraf başarıyla yüklendi.",
  "code": 201,
  "errors": null,
  "timestamp": "2026-07-15T10:32:00.000Z"
}
```

### 4.2. Fotoğrafı getirme

`GET /photos/{id}` · **Anonim**

Request Body: Yok.

Response (`200 OK`): JSON zarfı yerine `image/jpeg`, `image/png` veya `image/webp` binary içeriği döner.

---

## 5. Kategori ve Ürün Endpointleri

### 5.1. Kategorileri listeleme

`GET /categories` · **Anonim**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": [
    {
      "id": "cat_electronics",
      "name": "Elektronik",
      "slug": "elektronik",
      "iconId": "img_cat_electronics",
      "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
      "parentCategoryId": null,
      "productCount": 120,
      "children": [
        {
          "id": "cat_computers",
          "name": "Bilgisayar",
          "slug": "bilgisayar",
          "iconId": "img_cat_computers",
          "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_computers",
          "parentCategoryId": "cat_electronics",
          "productCount": 70,
          "children": [
            {
              "id": "cat_laptops",
              "name": "Dizüstü Bilgisayar",
              "slug": "dizustu-bilgisayar",
              "iconId": "img_cat_laptops",
              "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_laptops",
              "parentCategoryId": "cat_computers",
              "productCount": 42,
              "children": []
            },
            {
              "id": "cat_desktops",
              "name": "Masaüstü Bilgisayar",
              "slug": "masaustu-bilgisayar",
              "iconId": "img_cat_desktops",
              "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_desktops",
              "parentCategoryId": "cat_computers",
              "productCount": 28,
              "children": []
            }
          ]
        },
        {
          "id": "cat_headphones",
          "name": "Kulaklık",
          "slug": "kulaklik",
          "iconId": "img_cat_headphones",
          "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_headphones",
          "parentCategoryId": "cat_electronics",
          "productCount": 36,
          "children": []
        }
      ]
    }
  ],
  "isSuccess": true,
  "message": "Kategoriler listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:33:00.000Z"
}
```

Kategori hiyerarşisi kuralları:

- `data` dizisinin en üst seviyesinde yalnızca kök kategoriler bulunur.
- Her kategori kendi alt kategorilerini recursive `children` dizisinde taşır.
- Alt kategorisi olmayan kategorilerde `children: []` döner; `null` dönmez.
- Kök kategorilerde `parentCategoryId: null` döner.
- Alt kategorilerde `parentCategoryId`, doğrudan bağlı olduğu üst kategorinin ID'sidir.
- Her kategori `iconId` ve istemcinin doğrudan kullanabileceği `iconUrl` alanlarını döner.
- `productCount`, ilgili kategori ve onun tüm alt kategorilerindeki aktif ürünlerin toplamıdır.
- Frontend ağacı yeniden oluşturmaz; response'taki `children` yapısını doğrudan menü/filtre olarak kullanır.
- `GET /products?categoryId={id}` bir üst kategoriyle çağrıldığında o kategori ve tüm alt kategorilerindeki ürünleri döner.
- Ürün response'larındaki `category` alanı özet modeldir; burada `children` dönmez.

### 5.2. Ürünleri listeleme

`GET /products` · **Anonim**

Query parametreleri:

| Parametre | Tip | Açıklama |
|---|---|---|
| `page` | integer | Sayfa numarası |
| `size` | integer | Sayfa başı kayıt |
| `q` | string | Arama metni |
| `categoryId` | string | Kategori filtresi |
| `sellerId` | string | Satıcı filtresi |
| `minPrice` | decimal | Minimum fiyat |
| `maxPrice` | decimal | Maksimum fiyat |
| `inStock` | boolean | Yalnızca stokta olanlar |
| `sortBy` | string | `price_asc`, `price_desc`, `newest`, `rating_desc` |

Örnek istek:

```http
GET /api/v1/products?page=1&size=12&categoryId=cat_electronics&sortBy=price_asc
```

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "id": "prod_445566",
        "title": "Hi-Fi Pro Kablosuz Kulaklık",
        "description": "Gürültü engelleyici bluetooth kulaklık.",
        "price": 1899.99,
        "stock": 42,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
        "rating": 4.7,
        "category": {
          "id": "cat_electronics",
          "name": "Elektronik",
          "iconId": "img_cat_electronics",
          "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
          "parentCategoryId": null
        },
        "seller": {
          "id": "sel_1001",
          "storeName": "Tekno Dükkan",
          "logoId": "img_store_1001",
          "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_store_1001",
          "rating": 4.8
        }
      }
    ],
    "pageIndex": 1,
    "pageSize": 12,
    "totalCount": 120,
    "totalPages": 10
  },
  "isSuccess": true,
  "message": "Ürünler listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:34:00.000Z"
}
```

### 5.3. Ürün detayını getirme

`GET /products/{id}` · **Anonim**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "prod_445566",
    "title": "Hi-Fi Pro Kablosuz Kulaklık",
    "description": "Gürültü engelleyici ANC destekli bluetooth kulaklık.",
    "price": 1899.99,
    "stock": 42,
    "photoId": "img_554433",
    "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
    "photoIds": ["img_554433", "img_554434"],
    "photoUrls": [
      "https://api.ecommerce.com/api/v1/photos/img_554433",
      "https://api.ecommerce.com/api/v1/photos/img_554434"
    ],
    "rating": 4.7,
    "reviewCount": 128,
    "features": {
      "Renk": "Siyah",
      "Garanti": "2 Yıl"
    },
    "categoryId": "cat_electronics",
    "category": {
      "id": "cat_electronics",
      "name": "Elektronik",
      "iconId": "img_cat_electronics",
      "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
      "parentCategoryId": null
    },
    "seller": {
      "id": "sel_1001",
      "storeName": "Tekno Dükkan",
      "logoId": "img_store_1001",
      "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_store_1001",
      "rating": 4.8
    },
    "isActive": true,
    "createdAt": "2026-07-01T09:00:00.000Z",
    "updatedAt": "2026-07-14T12:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Ürün detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:35:00.000Z"
}
```

`GET /products/{id}` yorum listesini veya puan dağılımını dönmez; yorum endpointi çağrılmadan önce ürün ekranının özetini gösterebilmesi için yalnızca `rating` ve `reviewCount` alanlarını döner. `ratingDistribution` ve yorum kartları gerektiğinde `GET /products/{id}/reviews` ile alınır.

### 5.4. Ürün `features` alanı

`features`, ürün oluşturma ve güncelleme request'lerinde doğrudan gönderilir. Ayrı bir features endpointi kullanılmaz.

```json
{
  "features": {
    "Renk": "Siyah",
    "Garanti": "2 Yıl",
    "Bluetooth": "5.3"
  }
}
```

Kurallar:

- Her feature anahtar–değer çifti olarak gönderilir.
- Anahtar feature adını, değer ise kullanıcıya gösterilecek metni taşır.
- Tüm değerler string olarak gönderilir.
- Feature bulunmayan üründe `"features": {}` gönderilir.
- `POST /seller/products` ve `PUT /seller/products/{id}` aynı `features` formatını kullanır.
- Ürün detayında aynı nesne değiştirilmeden response içinde döner.

### 5.5. Ürün yorumları

Yorum kuralları:

- Yorumları herkes okuyabilir.
- Yorum ekleme, güncelleme ve silme için `Customer` rolü gerekir.
- Müşteri yalnızca teslim edilmiş bir siparişle satın aldığı ürüne yorum yazabilir.
- Bir müşteri aynı ürüne yalnızca bir yorum yazabilir.
- `rating` tam sayı olarak `1` ile `5` arasında olmalıdır.
- `comment` 10–1000 karakter arasında olmalıdır.
- Yorum fotoğrafları opsiyoneldir; bir yoruma en fazla 5 fotoğraf eklenebilir.
- Fotoğraflar önce `POST /photos` ile yüklenir, dönen `photoId` değerleri yorum request'indeki `photoIds` alanına yazılır.
- Fotoğrafsız yorum request'inde `"photoIds": []`, response'unda `"photos": []` kullanılır.
- Yorum güncellenirken korunması istenen eski ve yeni tüm fotoğraf ID'leri `photoIds` içinde birlikte gönderilir.
- Kullanıcı yalnızca kendi yorumunu güncelleyebilir veya silebilir.
- Ürün response'undaki `rating`, yorum puanlarının ortalamasıdır.

#### 5.5.1. Ürün yorumlarını listeleme

`GET /products/{id}/reviews?page=1&size=10&sortBy=newest` · **Anonim**

`sortBy` değerleri: `newest`, `oldest`, `rating_desc`, `rating_asc`.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "summary": {
      "averageRating": 4.7,
      "totalReviewCount": 128,
      "ratingDistribution": {
        "5": 96,
        "4": 20,
        "3": 8,
        "2": 3,
        "1": 1
      }
    },
    "items": [
      {
        "id": "rev_10001",
        "productId": "prod_445566",
        "user": {
          "id": "u_98124712",
          "displayName": "Rojhat Ç."
        },
        "rating": 5,
        "comment": "Ses kalitesi ve gürültü engelleme performansı oldukça iyi.",
        "photos": [
          {
            "photoId": "img_review_1001",
            "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_review_1001"
          }
        ],
        "isVerifiedPurchase": true,
        "createdAt": "2026-07-18T12:00:00.000Z",
        "updatedAt": null
      }
    ],
    "pageIndex": 1,
    "pageSize": 10,
    "totalCount": 128,
    "totalPages": 13
  },
  "isSuccess": true,
  "message": "Ürün yorumları getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-18T12:05:00.000Z"
}
```

#### 5.5.2. Ürüne yorum ekleme

`POST /products/{id}/reviews` · **Customer**

Request Body:

```json
{
  "rating": 5,
  "comment": "Ses kalitesi ve gürültü engelleme performansı oldukça iyi.",
  "photoIds": ["img_review_1001"]
}
```

Response Body (`201 Created`):

```json
{
  "data": {
    "id": "rev_10001",
    "productId": "prod_445566",
    "user": {
      "id": "u_98124712",
      "displayName": "Rojhat Ç."
    },
    "rating": 5,
    "comment": "Ses kalitesi ve gürültü engelleme performansı oldukça iyi.",
    "photos": [
      {
        "photoId": "img_review_1001",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_review_1001"
      }
    ],
    "isVerifiedPurchase": true,
    "createdAt": "2026-07-18T12:00:00.000Z",
    "updatedAt": null
  },
  "isSuccess": true,
  "message": "Yorum başarıyla eklendi.",
  "code": 201,
  "errors": null,
  "timestamp": "2026-07-18T12:00:00.000Z"
}
```

#### 5.5.3. Yorumu güncelleme

`PUT /products/{productId}/reviews/{reviewId}` · **Customer**

Request Body:

```json
{
  "rating": 4,
  "comment": "Ses kalitesi iyi, ancak kulak pedleri uzun kullanımda biraz rahatsız ediyor.",
  "photoIds": ["img_review_1001", "img_review_1002"]
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "rev_10001",
    "productId": "prod_445566",
    "user": {
      "id": "u_98124712",
      "displayName": "Rojhat Ç."
    },
    "rating": 4,
    "comment": "Ses kalitesi iyi, ancak kulak pedleri uzun kullanımda biraz rahatsız ediyor.",
    "photos": [
      {
        "photoId": "img_review_1001",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_review_1001"
      },
      {
        "photoId": "img_review_1002",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_review_1002"
      }
    ],
    "isVerifiedPurchase": true,
    "createdAt": "2026-07-18T12:00:00.000Z",
    "updatedAt": "2026-07-18T13:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Yorum başarıyla güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-18T13:00:00.000Z"
}
```

#### 5.5.4. Yorumu silme

`DELETE /products/{productId}/reviews/{reviewId}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Yorum başarıyla silindi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-18T13:05:00.000Z"
}
```

---

## 6. Favori Endpointleri

Tüm endpointler **Customer** rolü gerektirir.

### 6.1. Favorileri listeleme

`GET /favorites?page=1&size=12` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "id": "prod_445566",
        "title": "Hi-Fi Pro Kablosuz Kulaklık",
        "description": "Gürültü engelleyici bluetooth kulaklık.",
        "price": 1899.99,
        "stock": 42,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
        "rating": 4.7,
        "category": {
          "id": "cat_electronics",
          "name": "Elektronik",
          "iconId": "img_cat_electronics",
          "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
          "parentCategoryId": null
        },
        "seller": {
          "id": "sel_1001",
          "storeName": "Tekno Dükkan",
          "logoId": null,
          "logoUrl": null,
          "rating": 4.8
        }
      }
    ],
    "pageIndex": 1,
    "pageSize": 12,
    "totalCount": 1,
    "totalPages": 1
  },
  "isSuccess": true,
  "message": "Favoriler getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:36:00.000Z"
}
```

### 6.2. Favoriye ekleme

`POST /favorites/{productId}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "productId": "prod_445566",
    "addedAt": "2026-07-15T10:37:00.000Z"
  },
  "isSuccess": true,
  "message": "Ürün favorilere eklendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:37:00.000Z"
}
```

### 6.3. Favoriden kaldırma

`DELETE /favorites/{productId}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Ürün favorilerden kaldırıldı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:38:00.000Z"
}
```

---

## 7. Sepet Endpointleri

Tüm endpointler **Customer** rolü gerektirir.

### 7.1. Sepeti getirme

`GET /cart` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "productId": "prod_445566",
        "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
        "sellerId": "sel_1001",
        "sellerName": "Tekno Dükkan",
        "price": 1899.99,
        "quantity": 2,
        "totalPrice": 3799.98,
        "stock": 42,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
      }
    ],
    "subtotal": 3799.98,
    "totalAmount": 3799.98,
    "currency": "TRY"
  },
  "isSuccess": true,
  "message": "Sepet içeriği getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:39:00.000Z"
}
```

### 7.2. Sepete ürün ekleme

`POST /cart/items` · **Customer**

Request Body:

```json
{
  "productId": "prod_445566",
  "quantity": 1
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "productId": "prod_445566",
        "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
        "sellerId": "sel_1001",
        "sellerName": "Tekno Dükkan",
        "price": 1899.99,
        "quantity": 3,
        "totalPrice": 5699.97,
        "stock": 42,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
      }
    ],
    "subtotal": 5699.97,
    "totalAmount": 5699.97,
    "currency": "TRY"
  },
  "isSuccess": true,
  "message": "Ürün sepete eklendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:40:00.000Z"
}
```

### 7.3. Sepetteki miktarı güncelleme

`PUT /cart/items/{productId}` · **Customer**

Request Body:

```json
{
  "quantity": 5
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "productId": "prod_445566",
        "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
        "sellerId": "sel_1001",
        "sellerName": "Tekno Dükkan",
        "price": 1899.99,
        "quantity": 5,
        "totalPrice": 9499.95,
        "stock": 42,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
      }
    ],
    "subtotal": 9499.95,
    "totalAmount": 9499.95,
    "currency": "TRY"
  },
  "isSuccess": true,
  "message": "Sepet güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:41:00.000Z"
}
```

### 7.4. Sepetten ürün silme

`DELETE /cart/items/{productId}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [],
    "subtotal": 0.00,
    "totalAmount": 0.00,
    "currency": "TRY"
  },
  "isSuccess": true,
  "message": "Ürün sepetten silindi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:42:00.000Z"
}
```

### 7.5. Sepeti temizleme

`DELETE /cart` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Sepet temizlendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:43:00.000Z"
}
```

---

## 8. Satıcı Kargo Firması Endpointleri

### 8.1. Aktif kargo firmalarını listeleme

`GET /seller/shipping-carriers` · **Seller**

Admin tarafından tanımlanmış ve aktif durumdaki kargo firmalarını döner. Satıcı, hazırladığı paketi kargoya verirken bu listeden bir firma seçer.

Müşteri kargo firması seçmez. Bu endpoint yalnızca oturum açmış `Seller` tarafından kargolama akışında kullanılır.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": [
    {
      "id": "car_yurtici",
      "name": "Yurtiçi Kargo",
      "code": "YURTICI",
      "logoId": "img_car_yurtici",
      "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_car_yurtici",
      "flatFee": 49.90,
      "estimatedDeliveryDays": 3,
      "isActive": true
    },
    {
      "id": "car_aras",
      "name": "Aras Kargo",
      "code": "ARAS",
      "logoId": null,
      "logoUrl": null,
      "flatFee": 44.90,
      "estimatedDeliveryDays": 4,
      "isActive": true
    }
  ],
  "isSuccess": true,
  "message": "Aktif kargo firmaları listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:44:00.000Z"
}
```

`flatFee`, müşteriden checkout sırasında tahsil edilen bir tutar değildir; satıcının seçtiği firmaya ait operasyonel kargo maliyetidir. Firma seçildikten sonra paket üzerindeki `shippingFee` alanına yansır. Aynı satıcıdan alınan ürünler tek paket altında gösterilir.

Kargo firması logosu `logoId` ile saklanır; istemci gösterim için response'taki `logoUrl` alanını kullanır.

---

## 9. Ödeme Simülasyonu Endpointi

### 9.1. Ödeme simülasyonu

`POST /payments/simulate` · **Customer**

Frontend ve QA ekiplerinin ödeme ekranını sipariş oluşturmadan test etmesini sağlar.

Request Body:

```json
{
  "amount": 1899.99,
  "paymentCard": {
    "cardHolderName": "Rojhat Çetin",
    "cardNumber": "4355123456789012",
    "expireMonth": 12,
    "expireYear": 2030,
    "cvv": "123"
  }
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "transactionId": "txn_8877665544",
    "status": "Success",
    "processedAt": "2026-07-15T10:45:00.000Z"
  },
  "isSuccess": true,
  "message": "Ödeme simülasyonu başarıyla tamamlandı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:45:00.000Z"
}
```

QA test kuralı: `cvv: "000"` gönderildiğinde `422` ve `PAYMENT_DECLINED` hatası döner.

---

## 10. Müşteri Sipariş Endpointleri

Tüm endpointler **Customer** rolü gerektirir.

Sipariş durumları:

- `Paid`
- `Preparing`
- `PartiallyShipped`
- `Shipped`
- `PartiallyDelivered`
- `Delivered`
- `PartiallyCancelled`
- `Cancelled`

Paket durumları: `Paid`, `Preparing`, `Shipped`, `Delivered`, `Cancelled`.

Kargo durumları: `NotCreated`, `LabelCreated`, `InTransit`, `Delivered`, `Cancelled`.

### 10.1. Checkout ve sipariş oluşturma

`POST /orders/checkout` · **Customer**

Aktif sepeti siparişe dönüştürür. Müşteri yalnızca teslimat adresini ve ödeme bilgilerini gönderir; kargo firmasını daha sonra her paketin satıcısı seçer.

Headers:

```http
Authorization: Bearer <access_token>
Idempotency-Key: 5cb55e32-2054-4a3b-a5f2-0eb7d86bf617
```

Request Body:

```json
{
  "addressId": "adr_112233",
  "paymentCard": {
    "cardHolderName": "Rojhat Çetin",
    "cardNumber": "4355123456789012",
    "expireMonth": 12,
    "expireYear": 2030,
    "cvv": "123"
  }
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "orderId": "ord_998877",
    "orderNumber": "ORD-2026-0715-A8F2",
    "subtotal": 2799.98,
    "shippingAmount": 0.00,
    "totalAmount": 2799.98,
    "currency": "TRY",
    "status": "Paid",
    "createdAt": "2026-07-15T10:46:00.000Z",
    "shippingAddress": {
      "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:7",
      "city": "İstanbul",
      "district": "Avcılar",
      "zipCode": "34320",
      "phoneNumber": "+905551112233"
    },
    "trackingNumber": null,
    "trackingUrl": null,
    "items": [
      {
        "productId": "prod_445566",
        "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
        "sellerId": "sel_1001",
        "price": 1899.99,
        "quantity": 1,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
      },
      {
        "productId": "prod_778899",
        "productTitle": "Kablosuz Mouse",
        "sellerId": "sel_1002",
        "price": 899.99,
        "quantity": 1,
        "photoId": "img_778899",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_778899"
      }
    ],
    "packages": [
      {
        "packageId": "pkg_10001",
        "seller": {
          "id": "sel_1001",
          "storeName": "Tekno Dükkan",
          "logoId": null,
          "logoUrl": null,
          "rating": 4.8
        },
        "status": "Paid",
        "subtotal": 1899.99,
        "shippingFee": null,
        "items": [
          {
            "productId": "prod_445566",
            "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
            "sellerId": "sel_1001",
            "price": 1899.99,
            "quantity": 1,
            "photoId": "img_554433",
            "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
          }
        ],
        "shipment": {
          "shipmentId": null,
          "status": "NotCreated",
          "carrier": null,
          "trackingNumber": null,
          "trackingUrl": null,
          "shippedAt": null,
          "deliveredAt": null
        }
      },
      {
        "packageId": "pkg_10002",
        "seller": {
          "id": "sel_1002",
          "storeName": "Aksesuar Market",
          "logoId": null,
          "logoUrl": null,
          "rating": 4.6
        },
        "status": "Paid",
        "subtotal": 899.99,
        "shippingFee": null,
        "items": [
          {
            "productId": "prod_778899",
            "productTitle": "Kablosuz Mouse",
            "sellerId": "sel_1002",
            "price": 899.99,
            "quantity": 1,
            "photoId": "img_778899",
            "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_778899"
          }
        ],
        "shipment": {
          "shipmentId": null,
          "status": "NotCreated",
          "carrier": null,
          "trackingNumber": null,
          "trackingUrl": null,
          "shippedAt": null,
          "deliveredAt": null
        }
      }
    ]
  },
  "isSuccess": true,
  "message": "Sipariş alındı ve ödeme onaylandı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:46:00.000Z"
}
```

Kök seviyedeki `trackingNumber` ve `trackingUrl` tek paketli eski istemciler için korunur. Yeni istemciler her zaman `packages[].shipment` alanını kullanmalıdır.

Bu sürümde kargo firması ödeme sonrasında satıcı tarafından seçildiği için müşteriden kargo ücreti tahsil edilmez. Bu nedenle sipariş seviyesindeki `shippingAmount` her zaman `0.00`, `totalAmount` ise ürünlerin `subtotal` toplamıdır. Paket seviyesindeki `shippingFee`, satıcının operasyonel maliyetidir ve firma seçilene kadar `null` döner.

### 10.2. Siparişleri listeleme

`GET /orders?page=1&size=10&status=Paid` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "orderId": "ord_998877",
        "orderNumber": "ORD-2026-0715-A8F2",
        "totalAmount": 2799.98,
        "currency": "TRY",
        "status": "Paid",
        "createdAt": "2026-07-15T10:46:00.000Z",
        "itemCount": 2,
        "packageCount": 2
      }
    ],
    "pageIndex": 1,
    "pageSize": 10,
    "totalCount": 1,
    "totalPages": 1
  },
  "isSuccess": true,
  "message": "Siparişler getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:47:00.000Z"
}
```

### 10.3. Sipariş detayını getirme

`GET /orders/{id}` · **Customer**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "orderId": "ord_998877",
    "orderNumber": "ORD-2026-0715-A8F2",
    "subtotal": 1899.99,
    "shippingAmount": 0.00,
    "totalAmount": 1899.99,
    "currency": "TRY",
    "status": "Shipped",
    "createdAt": "2026-07-15T10:46:00.000Z",
    "shippingAddress": {
      "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:7",
      "city": "İstanbul",
      "district": "Avcılar",
      "zipCode": "34320",
      "phoneNumber": "+905551112233"
    },
    "trackingNumber": "KRG-123456789",
    "trackingUrl": "https://kargo.example/track/KRG-123456789",
    "items": [
      {
        "productId": "prod_445566",
        "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
        "sellerId": "sel_1001",
        "price": 1899.99,
        "quantity": 1,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
      }
    ],
    "packages": [
      {
        "packageId": "pkg_10001",
        "seller": {
          "id": "sel_1001",
          "storeName": "Tekno Dükkan",
          "logoId": null,
          "logoUrl": null,
          "rating": 4.8
        },
        "status": "Shipped",
        "subtotal": 1899.99,
        "shippingFee": 49.90,
        "items": [
          {
            "productId": "prod_445566",
            "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
            "sellerId": "sel_1001",
            "price": 1899.99,
            "quantity": 1,
            "photoId": "img_554433",
            "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
          }
        ],
        "shipment": {
          "shipmentId": "shp_10001",
          "status": "InTransit",
          "carrier": {
            "id": "car_yurtici",
            "name": "Yurtiçi Kargo",
            "code": "YURTICI"
          },
          "trackingNumber": "KRG-123456789",
          "trackingUrl": "https://kargo.example/track/KRG-123456789",
          "shippedAt": "2026-07-15T14:00:00.000Z",
          "deliveredAt": null
        }
      }
    ]
  },
  "isSuccess": true,
  "message": "Sipariş detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T15:00:00.000Z"
}
```

### 10.4. Siparişi iptal etme

`POST /orders/{id}/cancel` · **Customer**

Siparişte `Shipped` veya `Delivered` durumda paket yoksa iptal edilebilir.

Request Body:

```json
{
  "cancelReason": "Müşteri isteği üzerine"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "orderId": "ord_998877",
    "status": "Cancelled",
    "cancelledAt": "2026-07-15T10:50:00.000Z"
  },
  "isSuccess": true,
  "message": "Sipariş başarıyla iptal edildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T10:50:00.000Z"
}
```

---

## 11. Satıcı Endpointleri

Bu bölümdeki tüm endpointler **Seller** rolü gerektirir ve yalnızca oturumdaki satıcının verilerini döner.

### 11.1. Mağaza profilini getirme

`GET /seller/profile` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "sel_1001",
    "storeName": "Tekno Dükkan",
    "description": "Seçilmiş teknoloji ürünleri.",
    "logoId": "img_store_1001",
    "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_store_1001",
    "taxNumber": "1234567890",
    "taxOffice": "Avcılar",
    "rating": 4.8,
    "isActive": true,
    "createdAt": "2026-06-01T09:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Mağaza profili getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:00:00.000Z"
}
```

### 11.2. Mağaza profilini güncelleme

`PUT /seller/profile` · **Seller**

Request Body:

```json
{
  "storeName": "Tekno Dükkan",
  "description": "Tüketiciler için seçilmiş teknoloji ürünleri.",
  "logoId": "img_store_1001",
  "taxOffice": "Avcılar"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "sel_1001",
    "storeName": "Tekno Dükkan",
    "description": "Tüketiciler için seçilmiş teknoloji ürünleri.",
    "logoId": "img_store_1001",
    "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_store_1001",
    "taxNumber": "1234567890",
    "taxOffice": "Avcılar",
    "rating": 4.8,
    "isActive": true,
    "createdAt": "2026-06-01T09:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Mağaza profili güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:01:00.000Z"
}
```

### 11.3. Satıcı dashboard verilerini getirme

`GET /seller/dashboard?from=2026-07-01&to=2026-07-31` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "productCount": 24,
    "activeProductCount": 21,
    "lowStockProductCount": 3,
    "totalOrderCount": 128,
    "paidPackageCount": 6,
    "preparingPackageCount": 4,
    "shippedPackageCount": 9,
    "deliveredPackageCount": 105,
    "cancelledPackageCount": 4,
    "grossSalesAmount": 245430.50,
    "currency": "TRY"
  },
  "isSuccess": true,
  "message": "Satıcı dashboard verileri getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:02:00.000Z"
}
```

### 11.4. Satıcı ürünlerini listeleme

`GET /seller/products?page=1&size=10&q=&isActive=` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "id": "prod_445566",
        "title": "Hi-Fi Pro Kablosuz Kulaklık",
        "description": "ANC destekli bluetooth kulaklık.",
        "price": 1899.99,
        "stock": 42,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
        "rating": 4.7,
        "category": {
          "id": "cat_electronics",
          "name": "Elektronik",
          "iconId": "img_cat_electronics",
          "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
          "parentCategoryId": null
        },
        "seller": {
          "id": "sel_1001",
          "storeName": "Tekno Dükkan",
          "logoId": "img_store_1001",
          "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_store_1001",
          "rating": 4.8
        },
        "isActive": true
      }
    ],
    "pageIndex": 1,
    "pageSize": 10,
    "totalCount": 24,
    "totalPages": 3
  },
  "isSuccess": true,
  "message": "Satıcı ürünleri getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:03:00.000Z"
}
```

### 11.5. Satıcı ürün detayını getirme

`GET /seller/products/{id}` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "prod_445566",
    "title": "Hi-Fi Pro Kablosuz Kulaklık",
    "description": "ANC destekli bluetooth kulaklık.",
    "price": 1899.99,
    "stock": 42,
    "photoId": "img_554433",
    "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
    "photoIds": ["img_554433", "img_554434"],
    "photoUrls": [
      "https://api.ecommerce.com/api/v1/photos/img_554433",
      "https://api.ecommerce.com/api/v1/photos/img_554434"
    ],
    "rating": 4.7,
    "features": {
      "Renk": "Siyah",
      "Garanti": "2 Yıl"
    },
    "categoryId": "cat_electronics",
    "category": {
      "id": "cat_electronics",
      "name": "Elektronik",
      "iconId": "img_cat_electronics",
      "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
      "parentCategoryId": null
    },
    "isActive": true,
    "createdAt": "2026-07-01T09:00:00.000Z",
    "updatedAt": "2026-07-14T12:00:00.000Z"
  },
  "isSuccess": true,
  "message": "Satıcı ürün detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:04:00.000Z"
}
```

### 11.6. Ürün ekleme

`POST /seller/products` · **Seller**

Request Body:

```json
{
  "title": "Hi-Fi Pro Kablosuz Kulaklık",
  "description": "ANC destekli bluetooth kulaklık.",
  "price": 1899.99,
  "stock": 42,
  "categoryId": "cat_electronics",
  "photoIds": ["img_554433", "img_554434"],
  "features": {
    "Renk": "Siyah",
    "Garanti": "2 Yıl"
  },
  "isActive": true
}
```

Response Body (`201 Created`):

```json
{
  "data": {
    "id": "prod_445566",
    "title": "Hi-Fi Pro Kablosuz Kulaklık",
    "description": "ANC destekli bluetooth kulaklık.",
    "price": 1899.99,
    "stock": 42,
    "photoId": "img_554433",
    "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
    "photoIds": ["img_554433", "img_554434"],
    "photoUrls": [
      "https://api.ecommerce.com/api/v1/photos/img_554433",
      "https://api.ecommerce.com/api/v1/photos/img_554434"
    ],
    "rating": 0.0,
    "features": {
      "Renk": "Siyah",
      "Garanti": "2 Yıl"
    },
    "categoryId": "cat_electronics",
    "category": {
      "id": "cat_electronics",
      "name": "Elektronik",
      "iconId": "img_cat_electronics",
      "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
      "parentCategoryId": null
    },
    "isActive": true,
    "createdAt": "2026-07-15T11:05:00.000Z",
    "updatedAt": "2026-07-15T11:05:00.000Z"
  },
  "isSuccess": true,
  "message": "Ürün başarıyla eklendi.",
  "code": 201,
  "errors": null,
  "timestamp": "2026-07-15T11:05:00.000Z"
}
```

### 11.7. Ürün güncelleme

`PUT /seller/products/{id}` · **Seller**

Request Body:

```json
{
  "title": "Hi-Fi Pro 2 Kablosuz Kulaklık",
  "description": "Güncellenmiş ANC destekli bluetooth kulaklık.",
  "price": 1999.99,
  "stock": 38,
  "categoryId": "cat_electronics",
  "photoIds": ["img_554433", "img_554434"],
  "features": {
    "Renk": "Siyah",
    "Garanti": "2 Yıl"
  },
  "isActive": true
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "prod_445566",
    "title": "Hi-Fi Pro 2 Kablosuz Kulaklık",
    "description": "Güncellenmiş ANC destekli bluetooth kulaklık.",
    "price": 1999.99,
    "stock": 38,
    "photoId": "img_554433",
    "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433",
    "photoIds": ["img_554433", "img_554434"],
    "photoUrls": [
      "https://api.ecommerce.com/api/v1/photos/img_554433",
      "https://api.ecommerce.com/api/v1/photos/img_554434"
    ],
    "rating": 4.7,
    "features": {
      "Renk": "Siyah",
      "Garanti": "2 Yıl"
    },
    "categoryId": "cat_electronics",
    "category": {
      "id": "cat_electronics",
      "name": "Elektronik",
      "iconId": "img_cat_electronics",
      "iconUrl": "https://api.ecommerce.com/api/v1/photos/img_cat_electronics",
      "parentCategoryId": null
    },
    "isActive": true,
    "createdAt": "2026-07-01T09:00:00.000Z",
    "updatedAt": "2026-07-15T11:06:00.000Z"
  },
  "isSuccess": true,
  "message": "Ürün başarıyla güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:06:00.000Z"
}
```

### 11.8. Ürünü kaldırma

`DELETE /seller/products/{id}` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Ürün satıştan kaldırıldı.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:07:00.000Z"
}
```

### 11.9. Satıcı sipariş paketlerini listeleme

`GET /seller/orders?page=1&size=10&status=Paid&from=&to=` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "packageId": "pkg_10001",
        "orderId": "ord_998877",
        "orderNumber": "ORD-2026-0715-A8F2",
        "status": "Paid",
        "itemCount": 1,
        "subtotal": 1899.99,
        "shippingFee": null,
        "customerName": "Rojhat Çetin",
        "createdAt": "2026-07-15T10:46:00.000Z"
      }
    ],
    "pageIndex": 1,
    "pageSize": 10,
    "totalCount": 1,
    "totalPages": 1
  },
  "isSuccess": true,
  "message": "Satıcı sipariş paketleri getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:08:00.000Z"
}
```

### 11.10. Satıcı sipariş paketi detayını getirme

`GET /seller/orders/{packageId}` · **Seller**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "packageId": "pkg_10001",
    "orderId": "ord_998877",
    "orderNumber": "ORD-2026-0715-A8F2",
    "status": "Paid",
    "createdAt": "2026-07-15T10:46:00.000Z",
    "customer": {
      "fullName": "Rojhat Çetin",
      "phoneNumber": "+905551112233"
    },
    "shippingAddress": {
      "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:7",
      "city": "İstanbul",
      "district": "Avcılar",
      "zipCode": "34320",
      "phoneNumber": "+905551112233"
    },
    "subtotal": 1899.99,
    "shippingFee": null,
    "items": [
      {
        "productId": "prod_445566",
        "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
        "price": 1899.99,
        "quantity": 1,
        "photoId": "img_554433",
        "photoUrl": "https://api.ecommerce.com/api/v1/photos/img_554433"
      }
    ],
    "shipment": {
      "shipmentId": null,
      "status": "NotCreated",
      "carrier": null,
      "trackingNumber": null,
      "trackingUrl": null,
      "shippedAt": null,
      "deliveredAt": null
    }
  },
  "isSuccess": true,
  "message": "Sipariş paketi detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:09:00.000Z"
}
```

### 11.11. Paketi hazırlamaya başlama

`POST /seller/orders/{packageId}/prepare` · **Seller**

Yalnızca `Paid` durumundaki paket için kullanılır.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "packageId": "pkg_10001",
    "orderId": "ord_998877",
    "status": "Preparing",
    "shipment": {
      "shipmentId": null,
      "status": "NotCreated",
      "trackingNumber": null,
      "trackingUrl": null
    }
  },
  "isSuccess": true,
  "message": "Paket hazırlanıyor.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:10:00.000Z"
}
```

### 11.12. Paketi kargoya verme

`POST /seller/orders/{packageId}/ship` · **Seller**

Yalnızca `Preparing` durumundaki paket için kullanılır. Satıcı, Admin tarafından eklenmiş aktif firmalardan birinin `carrierId` değerini ve aldığı takip numarasını birlikte gönderir.

`carrierId` zorunludur ve `GET /seller/shipping-carriers` response'unda bulunan aktif bir firmaya ait olmalıdır. Firma bulunamazsa `404`, pasifse veya paket uygun durumda değilse `400` global hata formatıyla döner.

Request Body:

```json
{
  "carrierId": "car_yurtici",
  "trackingNumber": "KRG-123456789"
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "packageId": "pkg_10001",
    "orderId": "ord_998877",
    "status": "Shipped",
    "shippingFee": 49.90,
    "shipment": {
      "shipmentId": "shp_10001",
      "status": "InTransit",
      "carrier": {
        "id": "car_yurtici",
        "name": "Yurtiçi Kargo",
        "code": "YURTICI"
      },
      "trackingNumber": "KRG-123456789",
      "trackingUrl": "https://kargo.example/track/KRG-123456789",
      "shippedAt": "2026-07-15T11:11:00.000Z",
      "deliveredAt": null
    }
  },
  "isSuccess": true,
  "message": "Paket kargoya verildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T11:11:00.000Z"
}
```

### 11.13. Paketi teslim edildi olarak işaretleme

`POST /seller/orders/{packageId}/deliver` · **Seller**

Demo kargo akışında yalnızca `Shipped` durumundaki paket için kullanılır.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "packageId": "pkg_10001",
    "orderId": "ord_998877",
    "status": "Delivered",
    "shipment": {
      "shipmentId": "shp_10001",
      "status": "Delivered",
      "carrier": {
        "id": "car_yurtici",
        "name": "Yurtiçi Kargo",
        "code": "YURTICI"
      },
      "trackingNumber": "KRG-123456789",
      "trackingUrl": "https://kargo.example/track/KRG-123456789",
      "shippedAt": "2026-07-15T11:11:00.000Z",
      "deliveredAt": "2026-07-17T14:30:00.000Z"
    }
  },
  "isSuccess": true,
  "message": "Paket teslim edildi olarak işaretlendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-17T14:30:00.000Z"
}
```

Satıcı paket akışı:

```text
Paid -> Preparing -> Shipped -> Delivered
Paid/Preparing -> Cancelled
```

---

## 12. Admin Endpointleri

Bu bölümdeki tüm endpointler **Admin** rolü gerektirir. Kullanıcı, satıcı ve sipariş endpointleri salt okunurdur. Adminin değiştirebildiği kaynak kargo firmalarıdır.

### 12.1. Admin dashboard verilerini getirme

`GET /admin/dashboard?from=2026-07-01&to=2026-07-31` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "totalUserCount": 12450,
    "newUserCount": 430,
    "totalSellerCount": 320,
    "activeSellerCount": 311,
    "totalProductCount": 18420,
    "activeProductCount": 17210,
    "totalOrderCount": 8450,
    "paidOrderCount": 120,
    "preparingOrderCount": 85,
    "shippedOrderCount": 210,
    "deliveredOrderCount": 7900,
    "cancelledOrderCount": 135,
    "grossSalesAmount": 2450000.75,
    "currency": "TRY"
  },
  "isSuccess": true,
  "message": "Admin dashboard verileri getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:00:00.000Z"
}
```

### 12.2. Kullanıcıları listeleme

`GET /admin/users?page=1&size=20&q=&isActive=` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "id": "u_98124712",
        "email": "rojhat.cetin@example.com",
        "firstName": "Rojhat",
        "lastName": "Çetin",
        "phoneNumber": "+905554443322",
        "isActive": true,
        "orderCount": 8,
        "totalSpent": 18450.75,
        "createdAt": "2026-03-15T12:00:00.000Z"
      }
    ],
    "pageIndex": 1,
    "pageSize": 20,
    "totalCount": 12450,
    "totalPages": 623
  },
  "isSuccess": true,
  "message": "Kullanıcılar listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:01:00.000Z"
}
```

### 12.3. Kullanıcı detayını getirme

`GET /admin/users/{id}` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "user": {
      "id": "u_98124712",
      "email": "rojhat.cetin@example.com",
      "firstName": "Rojhat",
      "lastName": "Çetin",
      "phoneNumber": "+905554443322",
      "createdAt": "2026-03-15T12:00:00.000Z"
    },
    "isActive": true,
    "orderCount": 8,
    "totalSpent": 18450.75,
    "lastOrderAt": "2026-07-15T10:46:00.000Z"
  },
  "isSuccess": true,
  "message": "Kullanıcı detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:02:00.000Z"
}
```

### 12.4. Satıcıları listeleme

`GET /admin/sellers?page=1&size=20&q=&isActive=` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "id": "sel_1001",
        "storeName": "Tekno Dükkan",
        "ownerFullName": "Ayşe Yılmaz",
        "email": "magaza@example.com",
        "phoneNumber": "+905551234567",
        "isActive": true,
        "productCount": 24,
        "orderCount": 128,
        "grossSalesAmount": 245430.50,
        "createdAt": "2026-06-01T09:00:00.000Z"
      }
    ],
    "pageIndex": 1,
    "pageSize": 20,
    "totalCount": 320,
    "totalPages": 16
  },
  "isSuccess": true,
  "message": "Satıcılar listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:03:00.000Z"
}
```

### 12.5. Satıcı detayını getirme

`GET /admin/sellers/{id}` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "seller": {
      "id": "sel_1001",
      "storeName": "Tekno Dükkan",
      "description": "Seçilmiş teknoloji ürünleri.",
      "logoId": "img_store_1001",
      "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_store_1001",
      "taxNumber": "1234567890",
      "taxOffice": "Avcılar",
      "rating": 4.8,
      "isActive": true,
      "createdAt": "2026-06-01T09:00:00.000Z"
    },
    "ownerFullName": "Ayşe Yılmaz",
    "email": "magaza@example.com",
    "phoneNumber": "+905551234567",
    "productCount": 24,
    "orderCount": 128,
    "grossSalesAmount": 245430.50
  },
  "isSuccess": true,
  "message": "Satıcı detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:04:00.000Z"
}
```

### 12.6. Siparişleri listeleme

`GET /admin/orders?page=1&size=20&q=&status=&sellerId=&from=&to=` · **Admin**

`q`, sipariş numarası veya müşteri e-postasında arama yapar.

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "items": [
      {
        "orderId": "ord_998877",
        "orderNumber": "ORD-2026-0715-A8F2",
        "customerEmail": "rojhat.cetin@example.com",
        "totalAmount": 2799.98,
        "currency": "TRY",
        "status": "Paid",
        "itemCount": 2,
        "packageCount": 2,
        "createdAt": "2026-07-15T10:46:00.000Z"
      }
    ],
    "pageIndex": 1,
    "pageSize": 20,
    "totalCount": 8450,
    "totalPages": 423
  },
  "isSuccess": true,
  "message": "Siparişler listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:05:00.000Z"
}
```

### 12.7. Sipariş detayını getirme

`GET /admin/orders/{id}` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "customer": {
      "id": "u_98124712",
      "fullName": "Rojhat Çetin",
      "email": "rojhat.cetin@example.com",
      "phoneNumber": "+905554443322"
    },
    "order": {
      "orderId": "ord_998877",
      "orderNumber": "ORD-2026-0715-A8F2",
      "subtotal": 1899.99,
      "shippingAmount": 0.00,
      "totalAmount": 1899.99,
      "currency": "TRY",
      "status": "Shipped",
      "createdAt": "2026-07-15T10:46:00.000Z",
      "shippingAddress": {
        "addressLine": "Üniversite Mah. Bağlar İçi Cad. No:7",
        "city": "İstanbul",
        "district": "Avcılar",
        "zipCode": "34320",
        "phoneNumber": "+905551112233"
      },
      "items": [
        {
          "productId": "prod_445566",
          "productTitle": "Hi-Fi Pro Kablosuz Kulaklık",
          "sellerId": "sel_1001",
          "price": 1899.99,
          "quantity": 1
        }
      ],
      "packages": [
        {
          "packageId": "pkg_10001",
          "seller": {
            "id": "sel_1001",
            "storeName": "Tekno Dükkan"
          },
          "status": "Shipped",
          "shippingFee": 49.90,
          "shipment": {
            "shipmentId": "shp_10001",
            "status": "InTransit",
            "carrier": {
              "id": "car_yurtici",
              "name": "Yurtiçi Kargo",
              "code": "YURTICI"
            },
            "trackingNumber": "KRG-123456789",
            "trackingUrl": "https://kargo.example/track/KRG-123456789",
            "shippedAt": "2026-07-15T11:11:00.000Z",
            "deliveredAt": null
          }
        }
      ]
    }
  },
  "isSuccess": true,
  "message": "Sipariş detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:06:00.000Z"
}
```

### 12.8. Tüm kargo firmalarını listeleme

`GET /admin/shipping-carriers?includeInactive=true` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": [
    {
      "id": "car_yurtici",
      "name": "Yurtiçi Kargo",
      "code": "YURTICI",
      "logoId": "img_car_yurtici",
      "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_car_yurtici",
      "flatFee": 49.90,
      "estimatedDeliveryDays": 3,
      "trackingUrlTemplate": "https://kargo.example/track/{trackingNumber}",
      "isActive": true
    }
  ],
  "isSuccess": true,
  "message": "Kargo firmaları listelendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:07:00.000Z"
}
```

### 12.9. Kargo firması detayını getirme

`GET /admin/shipping-carriers/{id}` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "car_yurtici",
    "name": "Yurtiçi Kargo",
    "code": "YURTICI",
    "logoId": "img_car_yurtici",
    "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_car_yurtici",
    "flatFee": 49.90,
    "estimatedDeliveryDays": 3,
    "trackingUrlTemplate": "https://kargo.example/track/{trackingNumber}",
    "isActive": true
  },
  "isSuccess": true,
  "message": "Kargo firması detayı getirildi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:08:00.000Z"
}
```

### 12.10. Kargo firması ekleme

`POST /admin/shipping-carriers` · **Admin**

Logo önce `POST /photos` ile yüklenir ve dönen `photoId`, `logoId` olarak gönderilir. Backend response'ta buna ait `logoUrl` alanını da döner.

Request Body:

```json
{
  "name": "Yurtiçi Kargo",
  "code": "YURTICI",
  "logoId": "img_car_yurtici",
  "flatFee": 49.90,
  "estimatedDeliveryDays": 3,
  "trackingUrlTemplate": "https://kargo.example/track/{trackingNumber}",
  "isActive": true
}
```

Response Body (`201 Created`):

```json
{
  "data": {
    "id": "car_yurtici",
    "name": "Yurtiçi Kargo",
    "code": "YURTICI",
    "logoId": "img_car_yurtici",
    "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_car_yurtici",
    "flatFee": 49.90,
    "estimatedDeliveryDays": 3,
    "trackingUrlTemplate": "https://kargo.example/track/{trackingNumber}",
    "isActive": true
  },
  "isSuccess": true,
  "message": "Kargo firması eklendi.",
  "code": 201,
  "errors": null,
  "timestamp": "2026-07-15T12:09:00.000Z"
}
```

### 12.11. Kargo firması güncelleme

`PUT /admin/shipping-carriers/{id}` · **Admin**

Request Body:

```json
{
  "name": "Yurtiçi Kargo",
  "code": "YURTICI",
  "logoId": "img_car_yurtici_new",
  "flatFee": 54.90,
  "estimatedDeliveryDays": 2,
  "trackingUrlTemplate": "https://kargo.example/track/{trackingNumber}",
  "isActive": true
}
```

Response Body (`200 OK`):

```json
{
  "data": {
    "id": "car_yurtici",
    "name": "Yurtiçi Kargo",
    "code": "YURTICI",
    "logoId": "img_car_yurtici_new",
    "logoUrl": "https://api.ecommerce.com/api/v1/photos/img_car_yurtici_new",
    "flatFee": 54.90,
    "estimatedDeliveryDays": 2,
    "trackingUrlTemplate": "https://kargo.example/track/{trackingNumber}",
    "isActive": true
  },
  "isSuccess": true,
  "message": "Kargo firması güncellendi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:10:00.000Z"
}
```

### 12.12. Kargo firması silme

`DELETE /admin/shipping-carriers/{id}` · **Admin**

Request Body: Yok.

Response Body (`200 OK`):

```json
{
  "data": null,
  "isSuccess": true,
  "message": "Kargo firması silindi.",
  "code": 200,
  "errors": null,
  "timestamp": "2026-07-15T12:11:00.000Z"
}
```

---

## 13. Endpoint Kullanım Rehberi

### 13.1. Müşteri kayıt akışı

1. Kayıt formu gönderilir: `POST /auth/customer/register`
2. Response'taki `sessionId` ve `expiresAt` alınır.
3. OTP ekranı açılır.
4. Kod girilince: `POST /auth/email/verify`
5. Dönen access ve refresh token ile oturum açılır.
6. Kod süresi dolarsa: `POST /auth/email/resend`

### 13.2. Satıcı kayıt akışı

1. Satıcı ve mağaza formu gönderilir: `POST /auth/seller/register`
2. Response'taki `sessionId` ile OTP ekranı açılır.
3. Kod doğrulanır: `POST /auth/email/verify`
4. Response'taki `data.account.role` değeri `Seller` ise satıcı dashboard'una gidilir.

### 13.3. Login ve token yenileme akışı

1. `POST /auth/login`
2. Access token, refresh token, son kullanma tarihleri ve ortak `account` bilgisi alınır.
3. `data.account.role` değerine göre yönlendirme yapılır:
   - `Customer` → mağaza ana sayfası
   - `Seller` → satıcı dashboard'u
   - `Admin` → admin dashboard'u
4. Korumalı istek `401` dönerse bir kez `POST /auth/refresh-token` çağrılır.
5. Yenileme başarılıysa ilk istek yeni token ile tekrarlanır.
6. Yenileme başarısızsa oturum kapatılır ve login ekranı açılır.

### 13.4. Şifremi unuttum akışı

1. E-posta gönderilir: `POST /auth/forgot-password`
2. Response'taki `sessionId` alınır.
3. OTP, yeni şifre ve şifre tekrarı alınır.
4. `POST /auth/reset-password`
5. Başarılı response sonrası login ekranı açılır.

### 13.5. Katalog ve ürün detay akışı

1. Filtreleri doldurmak için: `GET /categories`
2. Ürün listesini getirmek için: `GET /products`
3. Arama, filtre veya sıralama değiştiğinde `GET /products` yeni query parametreleriyle tekrar çağrılır.
4. Ürün kartına tıklanınca: `GET /products/{id}`
5. Customer oturumu varsa:
   - Favoriye ekle: `POST /favorites/{productId}`
   - Sepete ekle: `POST /cart/items`

### 13.6. Ürün yorumları akışı

1. Ürün detayıyla birlikte ilk yorum sayfası çağrılır: `GET /products/{id}/reviews?page=1&size=10&sortBy=newest`
2. Sıralama veya sayfa değiştiğinde aynı endpoint yeni query parametreleriyle tekrar çağrılır.
3. Yorum fotoğrafı seçildiyse her fotoğraf için `POST /photos` çağrılır ve `photoId` değerleri toplanır.
4. Teslim edilmiş satın alımı bulunan Customer, `photoIds` dahil yorumunu ekler: `POST /products/{id}/reviews`
5. Kullanıcı kendi yorumunu düzenler: `PUT /products/{productId}/reviews/{reviewId}`
6. Kullanıcı kendi yorumunu siler: `DELETE /products/{productId}/reviews/{reviewId}`
7. Ekleme, güncelleme veya silme sonrası yorum listesi ve `GET /products/{id}` response'u yenilenir.

### 13.7. Favori akışı

1. Favoriler ekranı: `GET /favorites?page=1&size=12`
2. Favoriye ekle: `POST /favorites/{productId}`
3. Favoriden kaldır: `DELETE /favorites/{productId}`
4. Ekleme/silme sonrası liste cache'i yenilenir veya ilgili kart yerel olarak güncellenir.

### 13.8. Sepet akışı

1. Sepeti göster: `GET /cart`
2. Yeni ürün ekle: `POST /cart/items`
3. Miktarı değiştir: `PUT /cart/items/{productId}`
4. Tek ürünü sil: `DELETE /cart/items/{productId}`
5. Tüm sepeti temizle: `DELETE /cart`

### 13.9. Checkout akışı

1. Sepet: `GET /cart`
2. Teslimat adresleri: `GET /customer/me/addresses`
3. Adres yoksa: `POST /customer/me/addresses`
4. Frontend yeni bir `Idempotency-Key` oluşturur.
5. Seçilen `addressId` ve ödeme bilgileriyle sipariş oluşturulur: `POST /orders/checkout`
6. Başarılı response'taki `orderId` ile sipariş onay ekranı açılır.
7. Kullanıcı tekrar dene butonuna basarsa aynı checkout denemesinde aynı `Idempotency-Key` kullanılır.

Müşteri bu akışta kargo firması seçmez. Yeni paketlerde `shippingFee` ve `shipment.carrier` alanları, satıcı paketi kargoya verene kadar `null` döner.

### 13.10. Müşteri sipariş takip ve iptal akışı

1. Sipariş geçmişi: `GET /orders?page=1&size=10`
2. Sipariş detayı: `GET /orders/{id}`
3. Kargo bilgileri her paket için `packages[].shipment` alanından gösterilir.
4. Hiçbir paket `Shipped` veya `Delivered` değilse iptal butonu gösterilir.
5. İptal onayı: `POST /orders/{id}/cancel`
6. İptalden sonra sipariş detayı veya listesi yenilenir.

### 13.11. E-posta değiştirme akışı

1. Yeni e-posta ve mevcut şifre gönderilir: `PUT /account/me/email`
2. Response'taki `sessionId` ile OTP ekranı açılır.
3. Kod doğrulanır: `POST /account/me/email/verify`
4. Kod süresi dolarsa: `POST /account/me/email/resend`
5. Profil yenilenir: `GET /account/me`

### 13.12. Satıcı ürün ekleme akışı

1. Kategoriler: `GET /categories`
2. Her ürün fotoğrafı için: `POST /photos`
3. Dönen `photoId` değerleri `photoIds` listesine eklenir.
4. Ürün oluşturulur: `POST /seller/products`
5. Liste yenilenir: `GET /seller/products`

### 13.13. Satıcı sipariş ve kargo akışı

1. Yeni paketleri listele: `GET /seller/orders?status=Paid`
2. Paket detayı: `GET /seller/orders/{packageId}`
3. Hazırlamaya başla: `POST /seller/orders/{packageId}/prepare`
4. Admin'in eklediği aktif firmaları listele: `GET /seller/shipping-carriers`
5. Satıcı bir firma seçer ve kargo firmasından takip numarası alır.
6. Seçilen `carrierId` ve `trackingNumber` ile kargoya ver: `POST /seller/orders/{packageId}/ship`
7. Demo teslim işlemi: `POST /seller/orders/{packageId}/deliver`

Buton görünürlüğü:

| Paket durumu | Gösterilecek işlem |
|---|---|
| `Paid` | Hazırlamaya başla |
| `Preparing` | Kargoya ver |
| `Shipped` | Teslim edildi olarak işaretle |
| `Delivered` | İşlem butonu yok |
| `Cancelled` | İşlem butonu yok |

### 13.14. Admin dashboard akışı

1. Özet kartları: `GET /admin/dashboard?from=&to=`
2. Kullanıcı kartına tıklanırsa: `GET /admin/users`
3. Satıcı kartına tıklanırsa: `GET /admin/sellers`
4. Sipariş kartına tıklanırsa: `GET /admin/orders`
5. Liste satırına tıklanınca ilgili `/{id}` detay endpointi çağrılır.
6. Admin bu ekranlarda veri değiştirme butonu görmez.

### 13.15. Admin kargo firması yönetim akışı

Listeleme:

1. `GET /admin/shipping-carriers?includeInactive=true`

Ekleme:

1. Logo seçilirse `POST /photos` ile yüklenir ve `photoId` alınır.
2. Form doldurulur ve alınan değer `logoId` alanına yazılır.
3. `POST /admin/shipping-carriers`
4. Liste yeniden getirilir.

Güncelleme:

1. `GET /admin/shipping-carriers/{id}`
2. Form response verisiyle doldurulur.
3. Logo değişirse yeni görsel `POST /photos` ile yüklenir ve yeni `logoId` alınır.
4. `PUT /admin/shipping-carriers/{id}`
5. Liste yeniden getirilir.

Silme:

1. Kullanıcıdan onay alınır.
2. `DELETE /admin/shipping-carriers/{id}`
3. Liste yeniden getirilir.

---

## 14. Ekran ve Endpoint Haritası

| Ekran | Kullanılan endpointler |
|---|---|
| Uygulama başlangıcı | `/metadata/statuses` |
| Müşteri kayıt | `/auth/customer/register`, `/auth/email/verify`, `/auth/email/resend` |
| Satıcı kayıt | `/auth/seller/register`, `/auth/email/verify`, `/auth/email/resend` |
| Login | `/auth/login`, `/auth/refresh-token`, `/auth/logout` |
| Şifremi unuttum | `/auth/forgot-password`, `/auth/reset-password` |
| Ana sayfa | `/categories`, `/products` |
| Ürün detay | `/products/{id}`, `/products/{id}/reviews`, `/photos`, `/favorites/{productId}`, `/cart/items` |
| Favoriler | `/favorites` |
| Sepet | `/cart`, `/cart/items/*` |
| Checkout | `/customer/me/addresses`, `/orders/checkout` |
| Siparişlerim | `/orders`, `/orders/{id}`, `/orders/{id}/cancel` |
| Müşteri hesabı ve adresleri | `/account/me`, `/customer/me/addresses`, `DELETE /customer/me` |
| Satıcı dashboard | `/seller/dashboard` |
| Satıcı hesabı ve mağaza profili | `/account/me`, `/seller/profile` |
| Satıcı ürünleri | `/seller/products`, `/photos`, `/categories` |
| Satıcı siparişleri | `/seller/orders`, `/seller/shipping-carriers`, prepare/ship/deliver endpointleri |
| Admin hesabı | `/account/me` |
| Admin dashboard | `/admin/dashboard` |
| Admin kullanıcılar | `/admin/users` |
| Admin satıcılar | `/admin/sellers` |
| Admin siparişler | `/admin/orders` |
| Admin kargo firmaları | `/admin/shipping-carriers` |
