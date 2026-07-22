/**
 * Backend OpenAPI şemasından otomatik üretilen tipler.
 *
 * Yenilemek için: `npm run generate:types`
 *
 * Not: Uygulamanın mevcut domain tipleri `src/types/api.ts` içinde kalır.
 * Bu dosya sözleşme tiplerine referans ve yeni entegrasyonlar içindir;
 * mevcut import'ları bozmamak için kademeli kullanım önerilir.
 */
import type { components, paths } from "@/types/api.generated";

export type { components, paths };

export type OpenApiSchemas = components["schemas"];

/** İstek gövdeleri — backend Swagger request modelleri */
export type OpenApiLoginRequest = OpenApiSchemas["LoginRequest"];
export type OpenApiRegisterCustomerRequest =
  OpenApiSchemas["RegisterCustomerRequest"];
export type OpenApiRegisterSellerRequest = OpenApiSchemas["RegisterSellerRequest"];
export type OpenApiCartItemRequest = OpenApiSchemas["CartItemRequest"];
export type OpenApiCheckoutRequest = OpenApiSchemas["CheckoutRequest"];
export type OpenApiPaymentCardRequest = OpenApiSchemas["PaymentCardRequest"];
export type OpenApiAddressWriteRequest = OpenApiSchemas["AddressWriteRequest"];
export type OpenApiSellerProductWriteRequest =
  OpenApiSchemas["SellerProductWriteRequest"];
export type OpenApiReviewWriteRequest = OpenApiSchemas["ReviewWriteRequest"];

/** Endpoint yolları — openapi-typescript `paths` haritası */
export type OpenApiPaths = paths;
