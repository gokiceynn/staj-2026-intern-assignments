import Link from "next/link";

const QUESTIONS = [
  {
    question: "Siparişimi nasıl takip edebilirim?",
    answer:
      "Siparişiniz kargoya verildiğinde size gönderilen takip numarası ile kargo firmasının sitesinden siparişinizi kolayca takip edebilirsiniz.",
  },
  {
    question: "Ürün iadesi nasıl yapılır?",
    answer:
      "Ürün teslim alındıktan sonraki 14 gün içinde iade talebi oluşturabilirsiniz. İade sürecini başlatmak için Hesabım > Siparişler sayfasını kullanın.",
  },
  {
    question: "Kargo ücretleri nasıl hesaplanır?",
    answer:
      "Kargo ücreti, seçtiğiniz ürünlerin ağırlığı ve teslimat adresine göre otomatik olarak hesaplanır. Bazı kampanyalarda ücretsiz kargo fırsatı sunulmaktadır.",
  },
  {
    question: "Ödeme seçenekleriniz nelerdir?",
    answer:
      "Kredi kartı, banka kartı ve kapıda ödeme seçenekleri ile alışveriş yapabilirsiniz. Kampanyalı taksit seçenekleri dönemsel olarak değişebilir.",
  },
  {
    question: "Müşteri desteğe nasıl ulaşabilirim?",
    answer:
      "İletişim sayfamızdaki formu doldurarak destek talebi oluşturabilirsiniz. Ayrıca destek@vbshop.com adresine e-posta gönderebilirsiniz.",
  },
];

export default function FAQPage() {
  return (
    <main className="bg-surface-muted px-4 py-10 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-7xl">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-brand-600">
            Sık Sorulan Sorular
          </p>
          <h1 className="mt-4 text-3xl font-bold tracking-tight text-text sm:text-4xl">
            VBShop hakkında merak ettikleriniz
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-base text-text-muted sm:text-lg">
            Alışveriş, teslimat ve iade süreçleri hakkında sık sorulan soruları buradan inceleyebilirsiniz.
          </p>
        </div>

        <div className="mt-12 grid gap-8 xl:grid-cols-2 xl:items-stretch">
          <section className="flex min-h-[580px] flex-col rounded-[2rem] border border-border bg-white/95 p-8 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:bg-slate-950/95">
            <div className="space-y-5">
              {QUESTIONS.map((item, index) => (
                <details
                  key={item.question}
                  className="group overflow-hidden rounded-[1.5rem] border border-border bg-surface p-6 transition hover:border-brand-200 hover:bg-brand-50/70 dark:bg-slate-900/80 dark:hover:bg-slate-900"
                >
                  <summary className="cursor-pointer text-lg font-semibold text-text transition-colors group-open:text-brand-600">
                    {item.question}
                  </summary>
                  <p className="mt-4 text-sm leading-7 text-text-muted">{item.answer}</p>
                </details>
              ))}
            </div>
          </section>

          <aside className="flex min-h-[580px] flex-col rounded-[2rem] border border-border bg-gradient-to-br from-brand-50 via-white to-surface p-8 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:from-slate-900 dark:via-slate-950 dark:to-slate-950/95">
            <div className="flex flex-1 flex-col rounded-[1.75rem] bg-white/90 p-6 shadow-lg ring-1 ring-black/5 backdrop-blur dark:bg-slate-950/85 dark:ring-white/10">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">
                  Hızlı Yardım
                </p>
                <h2 className="mt-4 text-2xl font-semibold text-text">Hala sorunuz mu var?</h2>
                <p className="mt-4 text-sm leading-7 text-text-muted">
                  Eğer cevap bulamadıysanız iletişim sayfamızdan bize yazabilirsiniz. Size en kısa sürede yardımcı olacağız.
                </p>
              </div>

              <div className="mt-8 space-y-4 flex-1">
                <div className="rounded-3xl bg-surface px-5 py-4 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="font-semibold text-text">Canlı Destek</p>
                  <p className="mt-2 text-sm text-text-muted">Hafta içi 09:00 - 18:00 arası destek hizmeti.</p>
                </div>
                <div className="rounded-3xl bg-surface px-5 py-4 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                  <p className="font-semibold text-text">E-posta</p>
                  <p className="mt-2 text-sm text-text-muted">destek@vbshop.com</p>
                </div>
              </div>

              <Link href="/iletisim" className="mt-8 inline-flex w-full items-center justify-center rounded-2xl bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700">
                İletişim Sayfasına Git
              </Link>
            </div>
          </aside>
        </div>
      </div>
    </main>
  );
}
