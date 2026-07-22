import Link from "next/link";

export default function AboutPage() {
  return (
    <main className="bg-surface-muted px-4 py-10 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-7xl">
        <div className="mx-auto max-w-4xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-brand-600">
            VBShop Hakkımızda
          </p>
          <h1 className="mt-4 text-3xl font-bold tracking-tight text-text sm:text-5xl">
            Alışverişin güvenilir adresi
          </h1>
          <p className="mx-auto mt-5 max-w-2xl text-base text-text-muted sm:text-lg">
            VBShop, modern e-ticaret deneyimini Türkiye’deki alışveriş tutkunlarına hızlı, güvenli ve keyifli bir yolculuk olarak sunmak için kuruldu.
          </p>
        </div>

        <div className="mt-12 grid gap-8 lg:grid-cols-2 xl:items-stretch">
          <section className="flex h-full min-h-[560px] flex-col justify-between rounded-[2rem] border border-border bg-white/95 p-8 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:bg-slate-950/95">
            <div className="space-y-5">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">Misyonumuz</p>
                <h2 className="mt-4 text-2xl font-semibold text-text">Her alışverişte memnuniyet</h2>
                <p className="mt-3 text-base leading-7 text-text-muted">
                  VBShop olarak hedefimiz, her müşterimize özenli bir alışveriş deneyimi sunmak; ürün çeşitliliğini, fiyat avantajını ve hızlı teslimatı bir araya getirmektir.
                </p>
              </div>

              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">Vizyonumuz</p>
                <h2 className="mt-4 text-2xl font-semibold text-text">Türkiye’nin en sevilen online mağazası</h2>
                <p className="mt-3 text-base leading-7 text-text-muted">
                  Yenilikçi e-ticaret yaklaşımımızla marka sadakati oluşturan, müşterinin ihtiyaçlarına hızlı cevap veren bir platform olmayı amaçlıyoruz.
                </p>
              </div>
            </div>

            <div className="grid gap-4 sm:grid-cols-3">
              <div className="rounded-[1.5rem] bg-brand-50 p-5 text-center shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                <p className="text-3xl font-bold text-brand-600">10K+</p>
                <p className="mt-2 text-sm text-text-muted">Mutlu Müşteri</p>
              </div>
              <div className="rounded-[1.5rem] bg-brand-50 p-5 text-center shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                <p className="text-3xl font-bold text-brand-600">24/7</p>
                <p className="mt-2 text-sm text-text-muted">Destek Hizmeti</p>
              </div>
              <div className="rounded-[1.5rem] bg-brand-50 p-5 text-center shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                <p className="text-3xl font-bold text-brand-600">1000+</p>
                <p className="mt-2 text-sm text-text-muted">Ürün Kategorisi</p>
              </div>
            </div>
          </section>

          <section className="flex h-full min-h-[560px] flex-col justify-between overflow-hidden rounded-[2rem] border border-border bg-gradient-to-br from-brand-50 via-white to-surface p-8 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:from-slate-900 dark:via-slate-950 dark:to-slate-950/95">
            <div className="space-y-6 rounded-[1.75rem] bg-white/90 p-6 shadow-lg ring-1 ring-black/5 backdrop-blur dark:bg-slate-950/85 dark:ring-white/10">
              <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">Neden VBShop?</p>
              <div className="space-y-4 text-text-muted">
                <div className="rounded-3xl bg-surface px-5 py-4 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="font-semibold text-text">Güvenli Ödeme</p>
                  <p className="mt-2 text-sm">Kredi kartı, kapıda ödeme ve taksit seçenekleri ile güvenli alışveriş sağlıyoruz.</p>
                </div>
                <div className="rounded-3xl bg-surface px-5 py-4 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="font-semibold text-text">Hızlı Teslimat</p>
                  <p className="mt-2 text-sm">Ankara merkezli depomuz sayesinde hızlı ve güvenilir kargo deneyimi sunuyoruz.</p>
                </div>
                <div className="rounded-3xl bg-surface px-5 py-4 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="font-semibold text-text">Kolay İade</p>
                  <p className="mt-2 text-sm">Şeffaf iade politikamız ile memnun kalmadığınız ürünü hızlıca geri alıyoruz.</p>
                </div>
              </div>
              <div className="mt-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <Link href="/iletisim" className="inline-flex items-center justify-center rounded-2xl bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700">
                  İletişim Sayfasına Git
                </Link>
                <p className="text-sm text-text-muted sm:text-right">VBShop ailesine katılın ve alışverişinizi bir üst seviyeye taşıyın.</p>
              </div>
            </div>
          </section>
        </div>
      </div>
    </main>
  );
}
