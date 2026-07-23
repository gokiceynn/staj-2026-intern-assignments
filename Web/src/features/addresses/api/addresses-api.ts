import { apiClient } from "@/lib/api/client";
import type { Address } from "@/types/api";
import type { AddressInput } from "@/features/addresses/schemas/address";

export const addressesApi = {
  list: async (): Promise<Address[]> => {
    const data = await apiClient<{ items: Address[] } | Address[]>(
      "customer/me/addresses",
    );
    if (Array.isArray(data)) return data;
    return data.items ?? [];
  },

  getById: (id: string) => apiClient<Address>(`customer/me/addresses/${id}`),

  create: (input: AddressInput) =>
    apiClient<Address>("customer/me/addresses", { method: "POST", body: input }),

  update: (id: string, input: AddressInput) =>
    apiClient<Address>(`customer/me/addresses/${id}`, {
      method: "PUT",
      body: input,
    }),

  remove: (id: string) =>
    apiClient<null>(`customer/me/addresses/${id}`, { method: "DELETE" }),
};
