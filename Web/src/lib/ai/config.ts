/**
 * Sunucu tarafı Gemini yapılandırması.
 * GEMINI_API_KEY yalnızca .env.local içinde tutulur; istemciye sızdırılmaz.
 * Model seçimi yalnızca GEMINI_MODEL env değişkeni üzerinden yapılır.
 */
export type GeminiConfig = {
  apiKey: string;
  model: string;
};

const DEFAULT_GEMINI_MODEL = "gemini-3.1-flash-lite";

export function getGeminiModel(): string {
  return process.env.GEMINI_MODEL?.trim() || DEFAULT_GEMINI_MODEL;
}

export function getGeminiConfig(): GeminiConfig {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY tanımlı değil. Web/.env.local dosyasına ekleyin.");
  }

  return {
    apiKey,
    model: getGeminiModel(),
  };
}

export function isGeminiConfigured(): boolean {
  return Boolean(process.env.GEMINI_API_KEY?.trim());
}
