import { apiClient } from "@/lib/api/client";
import type { Address } from "@/types/api";
import type { AddressInput } from "@/features/addresses/schemas/address";

export const addressesApi = {
  list: () => apiClient<Address[]>("users/me/addresses"),

  getById: (id: string) => apiClient<Address>(`users/me/addresses/${id}`),

  create: (input: AddressInput) =>
    apiClient<Address>("users/me/addresses", { method: "POST", body: input }),

  update: (id: string, input: AddressInput) =>
    apiClient<Address>(`users/me/addresses/${id}`, {
      method: "PUT",
      body: input,
    }),

  remove: (id: string) =>
    apiClient<null>(`users/me/addresses/${id}`, { method: "DELETE" }),
};
