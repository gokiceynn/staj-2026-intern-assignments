"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import { aiApi } from "@/features/ai/api/ai-api";
import { queryKeys } from "@/lib/query/keys";
import type { AiChatInput } from "@/features/ai/schemas/ai";

export function useAiStatus() {
  return useQuery({
    queryKey: queryKeys.ai.status,
    queryFn: () => aiApi.status(),
    staleTime: 60_000,
  });
}

export function useAiChat() {
  return useMutation({
    mutationFn: (input: AiChatInput) => aiApi.chat(input),
  });
}
