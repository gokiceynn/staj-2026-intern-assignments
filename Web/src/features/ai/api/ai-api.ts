import type { AiChatRequest, AiChatResponse, AiStatusResponse } from "@/features/ai/types/ai";

async function parseJson<T>(response: Response): Promise<T> {
  const body = (await response.json()) as T & { error?: string };
  if (!response.ok) {
    throw new Error(body.error ?? "AI isteği başarısız oldu.");
  }
  return body;
}

export const aiApi = {
  status: () =>
    fetch("/api/ai/status", { cache: "no-store" }).then((r) =>
      parseJson<AiStatusResponse>(r),
    ),

  chat: (input: AiChatRequest) =>
    fetch("/api/ai/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(input),
    }).then((r) => parseJson<AiChatResponse>(r)),
};
