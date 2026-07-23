# API Sözleşmesi

Güncel kaynak: **[`ecommerce_api_contract_v1.3.md`](ecommerce_api_contract_v1.3.md)**

## Netleştirilmiş kararlar (özet)

| Konu | Karar |
|------|--------|
| Müşteri kaydı | `POST /auth/customer/register` |
| Satıcı kaydı | `POST /auth/seller/register` |
| `POST /auth/register` | **Kullanılmaz** |
| Profil | `GET/PUT /account/me` |
| Adresler | `/customer/me/addresses` |
| Hesap silme | `DELETE /customer/me` |
| `GET /customer/me` | Tanımlı değil |

Detay: sözleşme **§2.0**

## Frontend dokümantasyonu

- Web endpoint matrisi: [`Web/docs/API_ENDPOINT_MATRIX.md`](../Web/docs/API_ENDPOINT_MATRIX.md)
- Web API gaps: [`Web/docs/API_GAPS.md`](../Web/docs/API_GAPS.md)
- Mobil endpoint sabitleri: [`Mobile/lib/core/network/api_endpoints.dart`](../Mobile/lib/core/network/api_endpoints.dart)
