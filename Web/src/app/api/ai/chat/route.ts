import { NextRequest, NextResponse } from "next/server";
import { generateGeminiReply } from "@/lib/ai/gemini";
import { isGeminiConfigured } from "@/lib/ai/config";
import { aiChatSchema } from "@/features/ai/schemas/ai";

export async function POST(request: NextRequest) {
  if (!isGeminiConfigured()) {
    return NextResponse.json(
      { error: "GEMINI_API_KEY tanımlı değil. Web/.env.local dosyasını kontrol edin." },
      { status: 503 },
    );
  }

  try {
    const json = await request.json();
    const parsed = aiChatSchema.safeParse(json);

    if (!parsed.success) {
      return NextResponse.json(
        { error: parsed.error.issues[0]?.message ?? "Geçersiz istek" },
        { status: 400 },
      );
    }

    const reply = await generateGeminiReply(parsed.data.message);
    return NextResponse.json({ reply });
  } catch (err) {
    const message =
      err instanceof Error ? err.message : "AI yanıtı oluşturulamadı.";
    return NextResponse.json({ error: message }, { status: 502 });
  }
}
