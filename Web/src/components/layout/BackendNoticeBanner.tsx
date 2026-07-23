/**
 * Geçici uyarı — backend entegrasyonu tamamlanınca kaldır:
 * 1. Bu dosyayı sil
 * 2. layout.tsx içindeki <BackendNoticeBanner /> satırını kaldır
 */
export function BackendNoticeBanner() {
  return (
    <div
      role="status"
      className="border-b border-amber-300 bg-amber-50 px-4 py-2.5 text-center text-sm text-amber-950 dark:border-amber-700 dark:bg-amber-950/40 dark:text-amber-100"
    >
      <strong className="font-semibold">Geliştirme notu:</strong> Backend API
      henüz bağlı değil. Ürün listesi, giriş, sepet ve sipariş gibi özellikler
      API eklenene kadar sınırlı veya hata gösterebilir.
    </div>
  );
}
