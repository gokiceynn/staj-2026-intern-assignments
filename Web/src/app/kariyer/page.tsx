import Link from "next/link";

const OPEN_POSITIONS = [
  {
    title: "Satış ve Pazarlama Uzmanı",
    description: "E-ticaret ürünlerinin tanıtımını yapmak ve müşteri deneyimini güçlendirmek.",
  },
  {
    title: "Müşteri Deneyimi Yöneticisi",
    description: "Müşteri memnuniyetini artırmak için süreçleri ve destek akışını iyileştirmek.",
  },
  {
    title: "Depo ve Lojistik Koordinatörü",
    description: "Siparişlerin zamanında hazırlanması ve lojistik operasyonların yönetimi.",
  },
];

export default function CareersPage() {
  return (
    <main className="bg-surface-muted px-4 py-10 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-7xl">
        <div className="mx-auto max-w-4xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-brand-600">
            VBShop Kariyer
          </p>
          <h1 className="mt-4 text-3xl font-bold tracking-tight text-text sm:text-5xl">
            Ekibimize katılın
          </h1>
          <p className="mx-auto mt-5 max-w-2xl text-base text-text-muted sm:text-lg">
            Yaratıcı, enerjik ve çözüm odaklı bir ekipte yer almak ister misiniz? VBShop’ta kariyerinizi büyütün.
          </p>
        </div>

        <div className="mt-10 grid gap-8 lg:grid-cols-[1.15fr_0.85fr] xl:items-stretch">
          <section className="flex min-h-[520px] flex-col rounded-[2rem] border border-border bg-white/95 p-8 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:bg-slate-950/95">
            <div className="flex flex-col gap-6">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">
                  Neden VBShop?
                </p>
                <h2 className="mt-4 text-2xl font-semibold text-text">Kariyerinizi e-ticaretin geleceğiyle taçlandırın</h2>
                <p className="mt-4 text-base leading-7 text-text-muted">
                  VBShop, hızla büyüyen yapısı ve müşteri odaklı yaklaşımıyla yeni yeteneklere kapılarını açıyor. Burada kendinizi geliştirebilir, farklı disiplinlerde tecrübe kazanabilirsiniz.
                </p>
              </div>

              <div className="grid gap-4 grid-cols-1 sm:grid-cols-2">
                <div className="rounded-[1.5rem] bg-brand-50 p-5 shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                  <p className="text-sm font-semibold text-brand-600">Yaratıcı çalışma ortamı</p>
                  <p className="mt-2 text-sm text-text-muted">Özgür fikirlerin desteklendiği bir ekip kültürü.</p>
                </div>
                <div className="rounded-[1.5rem] bg-brand-50 p-5 shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                  <p className="text-sm font-semibold text-brand-600">Hızlı öğrenme fırsatı</p>
                  <p className="mt-2 text-sm text-text-muted">E-ticarette yenilikleri deneyerek öğrenin.</p>
                </div>
                <div className="rounded-[1.5rem] bg-brand-50 p-5 shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                  <p className="text-sm font-semibold text-brand-600">Takım ruhu</p>
                  <p className="mt-2 text-sm text-text-muted">Birlikte büyüyen bir ekipte yer alın.</p>
                </div>
                <div className="rounded-[1.5rem] bg-brand-50 p-5 shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                  <p className="text-sm font-semibold text-brand-600">Kariyer gelişimi</p>
                  <p className="mt-2 text-sm text-text-muted">Performans odaklı ilerleme ve gelişim.</p>
                </div>
                <div className="rounded-[1.5rem] bg-brand-50 p-5 shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                  <p className="text-sm font-semibold text-brand-600">Esnek çalışma saatleri</p>
                  <p className="mt-2 text-sm text-text-muted">Dengeli iş-yaşam için esnek planlama imkanı.</p>
                </div>
                <div className="rounded-[1.5rem] bg-brand-50 p-5 shadow-sm ring-1 ring-brand-100 dark:bg-slate-900/85">
                  <p className="text-sm font-semibold text-brand-600">Mentorluk desteği</p>
                  <p className="mt-2 text-sm text-text-muted">Deneyimli ekip arkadaşlarıyla birlikte gelişin.</p>
                </div>
              </div>
            </div>
          </section>

          <aside className="flex min-h-[520px] flex-col justify-between rounded-[2rem] border border-border bg-gradient-to-br from-brand-50 via-white to-surface p-8 shadow-[0_24px_80px_-40px_rgba(15,23,42,0.25)] backdrop-blur dark:from-slate-900 dark:via-slate-950 dark:to-slate-950/95">
            <div className="flex h-full flex-col justify-between rounded-[1.75rem] bg-white/90 p-6 shadow-lg ring-1 ring-black/5 backdrop-blur dark:bg-slate-950/85 dark:ring-white/10">
              <p className="text-sm font-semibold uppercase tracking-[0.28em] text-brand-600">
                Açık Pozisyonlar
              </p>
              <div className="mt-6 space-y-4">
                {OPEN_POSITIONS.map((position) => (
                  <div key={position.title} className="rounded-3xl bg-surface px-5 py-5 shadow-sm ring-1 ring-border dark:bg-slate-900/80">
                    <h3 className="text-base font-semibold text-text">{position.title}</h3>
                    <p className="mt-2 text-sm text-text-muted">{position.description}</p>
                  </div>
                ))}
              </div>

              <div className="mt-8 text-sm text-text-muted">
                <p className="font-semibold text-text">Başvuru</p>
                <p className="mt-2">
                  İlgilendiğiniz pozisyonları seçin ve info@vbshop.com adresine özgeçmişinizi gönderin.
                </p>
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
