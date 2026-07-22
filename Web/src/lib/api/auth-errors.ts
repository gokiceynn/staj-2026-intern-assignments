import { ApiError } from "@/lib/api/envelope";

const MESSAGES: Record<string, string> = {
  EMAIL_NOT_VERIFIED:
    "E-posta adresiniz henüz doğrulanmamış. Doğrulama sayfasından kodu girin.",
  RATE_LIMITED:
    "Çok fazla deneme yapıldı. Yaklaşık 15 dakika bekleyin veya doğrulama sayfasına gidin.",
  OTP_COOLDOWN:
    "Yeni kod henüz gönderilemiyor. Birkaç dakika bekleyin veya Mailpit (localhost:8026) adresine bakın.",
  INVALID_CREDENTIALS: "E-posta veya şifre hatalı.",
  EMAIL_ALREADY_EXISTS: "Bu e-posta adresi zaten kayıtlı.",
  ACCOUNT_LOCKED:
    "Hesabınız geçici olarak kilitlendi. 15 dakika sonra tekrar deneyin.",
};

export function getAuthErrorMessage(error: unknown, fallback = "İşlem başarısız"): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  const code = Object.keys(error.errors ?? {}).find((key) => MESSAGES[key]);
  if (code) {
    return MESSAGES[code]!;
  }

  const normalized = error.message.toLowerCase();
  if (normalized.includes("verification")) {
    return MESSAGES.EMAIL_NOT_VERIFIED!;
  }
  if (normalized.includes("too many")) {
    return MESSAGES.RATE_LIMITED!;
  }

  return error.message || fallback;
}

export function isAuthErrorCode(error: unknown, code: string): boolean {
  return error instanceof ApiError && Boolean(error.errors?.[code]);
}
