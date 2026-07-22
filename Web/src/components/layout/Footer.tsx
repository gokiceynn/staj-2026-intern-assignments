import Link from "next/link";

const LINKS = {
  Kurumsal: [
    { label: "Hakkımızda", href: "/hakkimizda" },
    { label: "Kariyer", href: "/kariyer" },
    { label: "İletişim", href: "/iletisim" },
  ],
  Yardım: [
    { label: "Sık Sorulan Sorular", href: "/sss" },
    { label: "Sipariş Takibi", href: "/orders" },
    { label: "İade & Değişim", href: "/products" },
  ],
  Hesap: [
    { label: "Giriş Yap", href: "/login" },
    { label: "Kayıt Ol", href: "/register" },
    { label: "Profilim", href: "/profile" },
  ],
};

export function Footer() {
  return (
    <footer className="mt-12 border-t border-border bg-surface">
      <div className="mx-auto max-w-7xl px-4 py-10">
        <div className="grid gap-8 md:grid-cols-4">
          <div>
            <p className="text-2xl font-extrabold text-brand-600">VBShop</p>
            <p className="mt-2 text-sm text-text-muted">
              Güvenilir alışverişin adresi. Binlerce ürün, hızlı teslimat.
            </p>
          </div>
          {Object.entries(LINKS).map(([title, items]) => (
            <div key={title}>
              <h3 className="font-semibold">{title}</h3>
              <ul className="mt-3 space-y-2">
                {items.map((item) => (
                  <li key={item.label}>
                    <Link
                      href={item.href}
                      className="text-sm text-text-muted hover:text-brand-600"
                    >
                      {item.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="mt-8 flex flex-col items-center justify-between gap-2 border-t border-border pt-6 text-xs text-text-muted md:flex-row">
          <p>© {new Date().getFullYear()} VBShop. Tüm hakları saklıdır.</p>
          <p>VB10 Staj 2026 · E-Ticaret Projesi</p>
        </div>
      </div>
    </footer>
  );
}
