# API Endpoint Matrix

Kaynak: `docs/ecommerce_api_contract_v1_detailed.pdf` (v1.0)

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

## Auth (`/auth`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| POST | `/auth/register` | Anonim | `email`, `password`, `passwordConfirm`, `firstName`, `lastName`, `phoneNumber` | `{ sessionId, expiresAt }` |
| POST | `/auth/login` | Anonim | `email`, `password` | `{ accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, user }` |
| POST | `/auth/logout` | Korumalı | — | `null` |
| POST | `/auth/refresh-token` | Kısmi (Bearer + body) | `{ refreshToken }` | `{ accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt }` |
| POST | `/auth/email/verify` | Anonim | `{ sessionId, code }` | Login ile aynı token + user |
| POST | `/auth/email/resend` | Anonim | `{ email }` | `{ sessionId, expiresAt }` |
| POST | `/auth/forgot-password` | Anonim | `{ email }` | `{ sessionId, expiresAt }` |
| POST | `/auth/reset-password` | Anonim | `{ sessionId, code, newPassword, newPasswordConfirm }` | `null` |

### User object (auth responses)

`id`, `email`, `firstName`, `lastName`, `phoneNumber`, `photoId`, `photoUrl`, `createdAt`

## Users (`/users`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| GET | `/users/me` | Korumalı | — | User |
| PUT | `/users/me` | Korumalı | `firstName`, `lastName`, `phoneNumber`, `photoId` | User |
| PUT | `/users/me/password` | Korumalı | `currentPassword`, `newPassword`, `newPasswordConfirm` | `null` |
| PUT | `/users/me/email` | Korumalı | `newEmail`, `password` | `{ sessionId, expiresAt }` |
| POST | `/users/me/email/verify` | Korumalı | `{ sessionId, code }` | `null` |
| POST | `/users/me/email/resend` | Korumalı | — (PDF body belirtmiyor; session bağlamı backend’de) | `{ sessionId, expiresAt }` |
| DELETE | `/users/me` | Korumalı | `{ password }` | `null` |

## Addresses (`/users/me/addresses`)

| Method | Path | Auth | Response `data` |
|--------|------|------|-----------------|
| GET | `/users/me/addresses` | Korumalı | `Address[]` |
| GET | `/users/me/addresses/{id}` | Korumalı | `Address` |
| POST | `/users/me/addresses` | Korumalı | `Address` (201) |
| PUT | `/users/me/addresses/{id}` | Korumalı | `Address` |
| DELETE | `/users/me/addresses/{id}` | Korumalı | `null` |

### Address object

`id`, `title`, `addressLine`, `city`, `district`, `zipCode`, `phoneNumber`

## Photos (`/photos`)

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| POST | `/photos` | Korumalı | `multipart/form-data`, field: `file` → `{ photoId, photoUrl, uploadedAt }` |
| GET | `/photos/{id}` | Anonim | Binary stream (no envelope) |

## Products (`/products`)

| Method | Path | Auth | Query params |
|--------|------|------|--------------|
| GET | `/products` | Anonim | `page`, `size`, `q`, `categoryId`, `minPrice`, `maxPrice`, `sortBy` |
| GET | `/products/{id}` | Anonim | — |

### Product list item

`id`, `title`, `description`, `price`, `stock`, `photoId`, `photoUrl`, `rating`, `category: { id, name }`

### Product detail (ek alanlar)

`features: Record<string, string>`, `categoryId`

### Pagination (list responses)

`pageIndex`, `pageSize`, `totalCount`, `totalPages`, `items[]`

PDF örneği `sortBy`: `price_asc`

## Cart (`/cart`)

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| GET | `/cart` | Korumalı | — | `{ items[], totalAmount }` |
| POST | `/cart/items` | Korumalı | `{ productId, quantity }` | Full cart |
| PUT | `/cart/items/{productId}` | Korumalı | `{ quantity }` | Full cart |

### Cart item

`productId`, `productTitle`, `price`, `quantity`, `totalPrice`, `photoId`, `photoUrl`

## Payments (`/payments`)

| Method | Path | Auth | Request | Response `data` |
|--------|------|------|---------|-----------------|
| POST | `/payments/simulate` | Korumalı | `{ amount, paymentCard }` | `{ transactionId, status, processedAt }` |

## Orders (`/orders`)

| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| POST | `/orders/checkout` | Korumalı | `{ addressId, paymentCard }` | Order detail |
| GET | `/orders` | Korumalı | — | Paginated order summaries |
| GET | `/orders/{id}` | Korumalı | — | Order detail |
| POST | `/orders/{id}/cancel` | Korumalı | `{ cancelReason }` | `{ orderId, status, cancelledAt }` |

### Order summary item

`orderId`, `orderNumber`, `totalAmount`, `status`, `createdAt`, `itemCount`

### Order detail

`orderId`, `orderNumber`, `totalAmount`, `status`, `createdAt`, `shippingAddress`, `items[]`
