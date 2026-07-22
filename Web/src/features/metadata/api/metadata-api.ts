import { apiClient } from "@/lib/api/client";
import type { StatusGroup } from "@/types/api";

export const metadataApi = {
  getStatuses: () => apiClient<StatusGroup[]>("metadata/statuses"),
};
