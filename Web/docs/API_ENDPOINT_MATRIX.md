# API Endpoint Matrix

Kaynak: [`Docs/ecommerce_api_contract_v1.3.md`](../../Docs/ecommerce_api_contract_v1.3.md)  
Netleştirilmiş kararlar: **§2.0** (`POST /auth/customer/register`; `POST /auth/register` kullanılmaz)

Base path: `/api/v1`

## Global envelope

```typescript
type ApiResponse<T> = {
  data: T | null;
  isSuccess: boolean;
  message: string;
  code: number;
  errors: Record<string, string[]> | null;
  timestamp: string;
};
```

**İstisna:** `GET /photos/{id}` standart JSON zarfı döndürmez; doğrudan binary image stream döner.

## Metadata (`/metadata`)

| Method | Path | Auth | Response `data` |
|--------|------|------|-----------------|
| GET | `/metadata/statuses` | Anonim | Sipariş/paket/kargo/ödeme durum etiketleri ve ikonları |

## Auth (`/auth`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| POST | `/auth/customer/register` | Anonim | `email`, `password`, `passwordConfirm`, `firstName`, `lastName`, `phoneNumber` | `{ sessionId, expiresAt }` |
| POST | `/auth/seller/register` | Anonim | müşteri alanları + `storeName`, `taxNumber`, `taxOffice` | `{ sessionId, expiresAt }` |
| POST | `/auth/login` | Anonim | `email`, `password` | `{ accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, account }` |
| POST | `/auth/logout` | Korumalı | — | `null` |
| POST | `/auth/refresh-token` | Kısmi (Bearer + body) | `{ refreshToken }` | `{ accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt }` |
| POST | `/auth/email/verify` | Anonim | `{ sessionId, code }` | Login ile aynı token + `account` |
| POST | `/auth/email/resend` | Anonim | `{ email }` | `{ sessionId, expiresAt }` |
| POST | `/auth/forgot-password` | Anonim | `{ email }` | `{ sessionId, expiresAt }` |
| POST | `/auth/reset-password` | Anonim | `{ sessionId, code, newPassword, newPasswordConfirm }` | `null` |

### Account object (auth responses)

`id`, `email`, `firstName`, `lastName`, `phoneNumber`, `role`, `createdAt`

## Account (`/account/me`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| GET | `/account/me` | Customer / Seller / Admin | — | Account |
| PUT | `/account/me` | Customer / Seller / Admin | `firstName`, `lastName`, `phoneNumber` | Account |
| PUT | `/account/me/password` | Customer / Seller / Admin | `currentPassword`, `newPassword`, `newPasswordConfirm` | `null` |
| PUT | `/account/me/email` | Customer / Seller / Admin | `newEmail`, `password` | `{ sessionId, expiresAt }` |
| POST | `/account/me/email/verify` | Customer / Seller / Admin | `{ sessionId, code }` | `null` |
| POST | `/account/me/email/resend` | Customer / Seller / Admin | `{ password }` | `{ sessionId, expiresAt }` |

## Customer (`/customer/me`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| DELETE | `/customer/me` | Customer | `{ password }` | `null` |

> `GET /customer/me` tanımlı değildir. Profil için `GET /account/me` kullanılır.

## Addresses (`/customer/me/addresses`)

| Method | Path | Auth | Response `data` |
|--------|------|------|-----------------|
| GET | `/customer/me/addresses` | Customer | `Address[]` |
| GET | `/customer/me/addresses/{id}` | Customer | `Address` |
| POST | `/customer/me/addresses` | Customer | `Address` (201) |
| PUT | `/customer/me/addresses/{id}` | Customer | `Address` |
| DELETE | `/customer/me/addresses/{id}` | Customer | `null` |

### Address object

`id`, `title`, `addressLine`, `city`, `district`, `zipCode`, `phoneNumber`

## Photos (`/photos`)

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| POST | `/photos` | Korumalı | `multipart/form-data`, field: `file` → `{ photoId, photoUrl, uploadedAt }` |
| GET | `/photos/{id}` | Anonim | Binary stream (no envelope) |

## Categories (`/categories`)

| Method | Path | Auth | Response `data` |
|--------|------|------|-----------------|
| GET | `/categories` | Anonim | Kök kategoriler + recursive `children` |

## Products (`/products`)

| Method | Path | Auth | Query params |
|--------|------|------|--------------|
| GET | `/products` | Anonim | `page`, `size`, `q`, `categoryId`, `sellerId`, `minPrice`, `maxPrice`, `inStock`, `sortBy` |
| GET | `/products/{id}` | Anonim | — |

### Product reviews

| Method | Path | Auth |
|--------|------|------|
| GET | `/products/{id}/reviews` | Anonim |
| POST | `/products/{id}/reviews` | Customer |
| PUT | `/products/{productId}/reviews/{reviewId}` | Customer |
| DELETE | `/products/{productId}/reviews/{reviewId}` | Customer |

### Pagination (list responses)

`pageIndex`, `pageSize`, `totalCount`, `totalPages`, `items[]`

`sortBy`: `price_asc`, `price_desc`, `newest`, `rating_desc`

## Favorites (`/favorites`)

| Method | Path | Auth |
|--------|------|------|
| GET | `/favorites?page=&size=` | Customer |
| POST | `/favorites/{productId}` | Customer |
| DELETE | `/favorites/{productId}` | Customer |

## Cart (`/cart`)

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| GET | `/cart` | Customer | — | `{ items[], subtotal, totalAmount, currency }` |
| POST | `/cart/items` | Customer | `{ productId, quantity }` | Full cart |
| PUT | `/cart/items/{productId}` | Customer | `{ quantity }` | Full cart |
| DELETE | `/cart/items/{productId}` | Customer | — | Full cart |
| DELETE | `/cart` | Customer | — | `null` |

## Payments (`/payments`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| POST | `/payments/simulate` | Customer | `{ amount, paymentCard }` | `{ transactionId, status, processedAt }` |

## Orders (`/orders`)

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| POST | `/orders/checkout` | Customer | `{ addressId, paymentCard }` + header `Idempotency-Key` | Order detail |
| GET | `/orders` | Customer | `page`, `size`, `status` | Paginated order summaries |
| GET | `/orders/{id}` | Customer | — | Order detail |
| POST | `/orders/{id}/cancel` | Customer | `{ cancelReason }` | `{ orderId, status, cancelledAt }` |
