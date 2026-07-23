"use client";

import { useEffect, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";

export default function ContactPage() {
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    if (!success) return;

    const timer = window.setTimeout(() => setSuccess(false), 4200);
    return () => window.clearTimeout(timer);
  }, [success]);

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setSuccess(true);
    setFirstName("");
    setLastName("");
    setEmail("");
    setSubject("");
    setMessage("");
  };

  return (
    <main className="bg-surface-muted px-4 py-10 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-7xl">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-brand-600">
            VBShop İletişim Merkezi
          </p>
          <h1 className="mt-4 text-3xl font-bold tracking-tight text-text sm:text-4xl">
            Sorularınız için buradayız
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-base text-text-muted sm:text-lg">
            Hızlı destek, net çözümler ve alışverişle ilgili her konuda yardımcı olmak için formu doldurun. Ekibimiz kısa sürede size dönüş yapsın.
          </p>
        </div>

        <div className="mt-12 grid gap-8 xl:grid-cols-[1.05fr_1.45fr]">
          <section className="group overflow-hidden rounded-[2rem] border border-border bg-gradient-to-br from-brand-50 via-white to-surface p-6 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:from-slate-900 dark:via-slate-950 dark:to-slate-950/95">
            <div className="rounded-[1.75rem] bg-white/90 p-6 shadow-lg ring-1 ring-black/5 backdrop-blur dark:bg-slate-950/85 dark:ring-white/10">
              <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="text-sm font-semibold uppercase tracking-[0.3em] text-brand-600">
                    Ofis Bilgileri
                  </p>
                  <h2 className="mt-4 text-2xl font-semibold text-text">VBShop Ankara Ofisi</h2>
                </div>
                <div className="inline-flex items-center gap-2 rounded-3xl bg-brand-600/10 px-4 py-2 text-sm font-semibold text-brand-700 ring-1 ring-brand-100 dark:bg-brand-500/10 dark:text-brand-200 dark:ring-brand-200/20">
                  <span className="text-base">📍</span>
                  Merkez Ofis
                </div>
              </div>

              <div className="mt-8 grid gap-4 text-sm sm:grid-cols-1 md:grid-cols-2 md:text-base">
                <div className="rounded-[1.75rem] bg-surface px-5 py-5 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="mb-2 text-xs uppercase tracking-[0.2em] text-text-muted">Adres</p>
                  <p className="font-semibold text-text">Çankaya Mah. Eskişehir Cad. No:45</p>
                  <p className="text-text-muted">Çankaya / Ankara</p>
                </div>
                <div className="rounded-[1.75rem] bg-surface px-5 py-5 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="mb-2 text-xs uppercase tracking-[0.2em] text-text-muted">Telefon</p>
                  <p className="font-semibold text-text">+90 312 987 65 43</p>
                  <p className="text-text-muted">Hafta içi 09:00 - 18:00</p>
                </div>
                <div className="rounded-[1.75rem] bg-surface px-5 py-5 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="mb-2 text-xs uppercase tracking-[0.2em] text-text-muted">E-posta</p>
                  <p className="font-semibold text-text">destek@vbshop.com</p>
                  <p className="text-text-muted">Soru ve teklif talepleri için</p>
                </div>
              </div>

              <div className="mt-8 grid gap-4 sm:grid-cols-2">
                <div className="rounded-3xl bg-brand-600/10 p-5 text-sm text-brand-700 ring-1 ring-brand-100 dark:bg-brand-500/10 dark:text-brand-200 dark:ring-brand-200/20">
                  <p className="font-semibold">Çalışma Saatleri</p>
                  <p className="mt-2">Pzt - Cuma: 09:00 - 18:00</p>
                </div>
                <div className="rounded-3xl bg-brand-600/10 p-5 text-sm text-brand-700 ring-1 ring-brand-100 dark:bg-brand-500/10 dark:text-brand-200 dark:ring-brand-200/20">
                  <p className="font-semibold">Yanıt Sözümüz</p>
                  <p className="mt-2">Mesajlara 24 saat içinde dönüş yapılır.</p>
                </div>
              </div>

              <div className="mt-8 grid gap-4 sm:grid-cols-2">
                <div className="rounded-[1.5rem] bg-white/90 p-5 shadow-sm ring-1 ring-border dark:bg-slate-950/85">
                  <p className="text-sm font-semibold text-text">Canlı Destek</p>
                  <p className="mt-2 text-xs text-text-muted">Hafta içi canlı destek hattı.</p>
                </div>
                <div className="rounded-[1.5rem] bg-white/90 p-5 shadow-sm ring-1 ring-border dark:bg-slate-950/85">
                  <p className="text-sm font-semibold text-text">E-ticaret Danışmanlığı</p>
                  <p className="mt-2 text-xs text-text-muted">Ürün, kampanya ve teslimat konularında destek.</p>
                </div>
              </div>
            </div>
          </section>

          <section className="overflow-hidden rounded-[2rem] border border-border bg-white/95 p-6 shadow-[0_28px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:bg-slate-950/95">
            <div className="rounded-[1.75rem] bg-surface px-6 py-8 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
              <div className="flex flex-col gap-2">
                <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">
                  Mesaj Gönder
                </p>
                <h2 className="text-2xl font-semibold text-text">Hemen bize yazın</h2>
                <p className="max-w-xl text-sm text-text-muted">
                  Formu doldurun, ekibimiz size hızlıca geri dönüş yapsın.
                </p>
              </div>

              {success && (
                <div className="mt-6 rounded-3xl bg-emerald-50 p-4 text-sm text-emerald-900 ring-1 ring-emerald-200">
                  Mesajınız başarıyla iletildi. En kısa sürede size geri döneceğiz.
                </div>
              )}

              <form onSubmit={handleSubmit} className="mt-8 space-y-5">
                <div className="grid gap-4 sm:grid-cols-2">
                  <Input
                    label="Ad"
                    value={firstName}
                    onChange={(event) => setFirstName(event.target.value)}
                    placeholder="Adınız"
                    className="rounded-2xl"
                    required
                  />
                  <Input
                    label="Soyad"
                    value={lastName}
                    onChange={(event) => setLastName(event.target.value)}
                    placeholder="Soyadınız"
                    className="rounded-2xl"
                    required
                  />
                </div>

                <Input
                  label="E-posta"
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="ornek@vbshop.com"
                  className="rounded-2xl"
                  required
                />
                <Input
                  label="Konu"
                  value={subject}
                  onChange={(event) => setSubject(event.target.value)}
                  placeholder="Mesaj başlığı"
                  className="rounded-2xl"
                  required
                />

                <label className="flex flex-col gap-3 text-sm font-medium text-text">
                  Mesaj
                  <textarea
                    value={message}
                    onChange={(event) => setMessage(event.target.value)}
                    placeholder="Mesajınızı buraya yazın..."
                    className="min-h-[180px] rounded-2xl border border-border bg-surface px-4 py-4 text-sm text-text placeholder:text-text-muted focus:border-brand-500 focus:outline-none"
                    required
                  />
                </label>

                <div className="flex justify-end">
                  <Button type="submit" size="lg" className="w-full sm:w-auto">
                    Mesajı Gönder
                  </Button>
                </div>
              </form>
            </div>
          </section>
        </div>
      </div>
    </main>
  );
}
