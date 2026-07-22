import { getGeminiConfig } from "@/lib/ai/config";

const VBSHOP_SYSTEM_PROMPT = `Sen VBShop e-ticaret sitesinin alışveriş asistanısın.
Kullanıcıya Türkçe, kısa ve net yanıt ver.
Ürün, sepet, sipariş ve site kullanımı hakkında yardımcı ol.
Stok, fiyat veya sipariş durumu sorulduğunda gerçek veriye erişemediğini belirt; tahmin uydurma.
Kaba veya alakasız istekleri nazikçe reddet.`;

type GeminiGenerateResponse = {
  candidates?: Array<{
    content?: {
      parts?: Array<{ text?: string }>;
    };
  }>;
  error?: { message?: string; status?: string };
};

function formatGeminiError(message: string): string {
  const lower = message.toLowerCase();

  if (lower.includes("quota") || lower.includes("rate limit")) {
    return (
      "Gemini API kotası doldu veya seçili model için ücretsiz limit yok. " +
      "Bir süre bekleyin, Google AI Studio'dan yeni key deneyin veya " +
      "Web/.env.local içinde GEMINI_MODEL değerini güncelleyin."
    );
  }

  if (lower.includes("api key") || lower.includes("invalid")) {
    return "Gemini API key geçersiz. Google AI Studio'dan yeni key alıp .env.local dosyasını güncelleyin.";
  }

  return message;
}

export async function generateGeminiReply(userMessage: string): Promise<string> {
  const { apiKey, model } = getGeminiConfig();
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    },
    body: JSON.stringify({
      system_instruction: {
        parts: [{ text: VBSHOP_SYSTEM_PROMPT }],
      },
      contents: [
        {
          role: "user",
          parts: [{ text: userMessage }],
        },
      ],
    }),
    cache: "no-store",
  });

  const body = (await response.json()) as GeminiGenerateResponse;

  if (!response.ok) {
    const raw = body.error?.message ?? "Gemini isteği başarısız oldu.";
    throw new Error(formatGeminiError(raw));
  }

  const text = body.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
  if (!text) {
    throw new Error("Gemini boş yanıt döndü.");
  }

  return text;
}
