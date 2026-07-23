"use client";

import { useQuery } from "@tanstack/react-query";
import { metadataApi } from "@/features/metadata/api/metadata-api";
import { queryKeys } from "@/lib/query/keys";

export function useStatuses() {
  return useQuery({
    queryKey: queryKeys.metadata.statuses,
    queryFn: () => metadataApi.getStatuses(),
    staleTime: 300_000,
  });
}

export function useOrderStatusLabel(status: string) {
  const { data } = useStatuses();
  const item = data
    ?.find((g) => g.key === "orders")
    ?.items.find((i) => i.code.toLowerCase() === status.toLowerCase());
  return item?.label ?? status;
}
