"use client";

import Image from "next/image";
import { FormEvent, useState } from "react";
import { useAiChat, useAiStatus } from "@/features/ai/queries/use-ai";
import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/utils/cn";

type Message = {
  role: "user" | "assistant";
  text: string;
};

export function AiAssistant() {
  const [open, setOpen] = useState(false);
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<Message[]>([]);
  const { data: status } = useAiStatus();
  const chat = useAiChat();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const text = input.trim();
    if (!text || chat.isPending) return;

    setInput("");
    setMessages((prev) => [...prev, { role: "user", text }]);

    try {
      const { reply } = await chat.mutateAsync({ message: text });
      setMessages((prev) => [...prev, { role: "assistant", text: reply }]);
    } catch (err) {
      const errorText =
        err instanceof Error ? err.message : "Yanıt alınamadı.";
      setMessages((prev) => [...prev, { role: "assistant", text: errorText }]);
    }
  };

  return (
    <div className="fixed bottom-20 right-4 z-50 flex flex-col items-end gap-2 md:bottom-4">
      {open && (
        <div className="flex h-[420px] w-[min(100vw-2rem,360px)] flex-col overflow-hidden rounded-xl border border-border bg-surface shadow-lg">
          <div className="relative border-b border-border bg-brand-500 px-4 py-3 pr-12 text-white">
            <button
              type="button"
              onClick={() => setOpen(false)}
              className="absolute right-3 top-3 flex h-8 w-8 items-center justify-center rounded-full bg-white/15 text-lg leading-none transition hover:bg-white/25"
              aria-label="Asistanı kapat"
            >
              ×
            </button>
            <h2 className="font-semibold">VBShop Asistan</h2>
            <p className="text-xs text-white/80">
              {status?.configured
                ? "Alışveriş sorularınız için buradayım."
                : "API key eklenince aktif olur (.env.local)."}
            </p>
          </div>

          <div className="flex-1 space-y-3 overflow-y-auto p-4">
            {messages.length === 0 && (
              <p className="text-sm text-text-muted">
                Örn: &quot;Sepetime nasıl ürün eklerim?&quot;
              </p>
            )}
            {messages.map((msg, i) => (
              <div
                key={i}
                className={cn(
                  "max-w-[85%] rounded-lg px-3 py-2 text-sm",
                  msg.role === "user"
                    ? "ml-auto bg-brand-50 text-text"
                    : "bg-surface-muted text-text",
                )}
              >
                {msg.text}
              </div>
            ))}
          </div>

          <form onSubmit={handleSubmit} className="border-t border-border p-3">
            <div className="flex gap-2">
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Mesajınızı yazın..."
                disabled={!status?.configured || chat.isPending}
                className="flex-1 rounded-md border border-border bg-surface px-3 py-2 text-sm text-text outline-none placeholder:text-text-muted focus:border-brand-500"
              />
              <Button
                type="submit"
                size="sm"
                loading={chat.isPending}
                disabled={!status?.configured}
              >
                Gönder
              </Button>
            </div>
          </form>
        </div>
      )}

      <div className="ai-assistant-float">
        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          className="cursor-pointer border-0 bg-transparent p-0 transition hover:scale-105 focus-visible:outline focus-visible:outline-2 focus-visible:outline-brand-500 focus-visible:outline-offset-2"
          aria-label="AI asistan"
        >
          <Image
            src="/aigorsel.png"
            alt="VBShop AI asistan"
            width={1536}
            height={1024}
            className="h-auto w-[14rem] bg-transparent md:w-[16rem]"
            priority
          />
        </button>
      </div>
    </div>
  );
}
