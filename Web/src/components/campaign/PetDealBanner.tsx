"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { PET_DEAL_CAMPAIGN } from "@/lib/campaigns/pet-deal";

const STORAGE_KEY = "vbshop:pet-deal-code";

export function PetDealBanner() {
  const { showToast } = useToast();
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    sessionStorage.setItem(STORAGE_KEY, PET_DEAL_CAMPAIGN.code);
  }, []);

  const copyCode = async () => {
    try {
      await navigator.clipboard.writeText(PET_DEAL_CAMPAIGN.code);
      setCopied(true);
      showToast("İndirim kodu kopyalandı", "success");
      setTimeout(() => setCopied(false), 2000);
    } catch {
      showToast("Kopyalanamadı — kodu elle seçin", "error");
    }
  };

  return (
    <div className="rounded-xl border border-brand-300 bg-gradient-to-r from-brand-50 via-orange-50 to-amber-50 p-5 shadow-card dark:border-brand-700/50 dark:from-slate-900 dark:via-slate-900 dark:to-slate-800 md:p-6">
      <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <p className="text-sm font-semibold uppercase tracking-wide text-brand-600">
            🎉 Tebrikler!
          </p>
          <h2 className="mt-1 text-lg font-bold text-text md:text-xl">
            Kedi & köpek ürünlerinde geçerli indirim kazandınız
          </h2>
          <p className="mt-2 text-sm text-text-muted">
            Aşağıdaki ürünlerde özel indirimler uygulandı. Sepette kodu kullanmayı
            unutmayın.
          </p>
        </div>

        <div className="flex shrink-0 flex-col items-stretch gap-2 sm:items-end">
          <span className="text-xs font-medium uppercase text-text-muted">
            İndirim kodunuz
          </span>
          <div className="flex items-center gap-2">
            <code className="rounded-lg border border-border bg-surface px-4 py-2 text-lg font-bold tracking-wider text-brand-600 dark:text-brand-200">
              {PET_DEAL_CAMPAIGN.code}
            </code>
            <Button type="button" variant="outline" size="sm" onClick={copyCode}>
              {copied ? "Kopyalandı" : "Kopyala"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
