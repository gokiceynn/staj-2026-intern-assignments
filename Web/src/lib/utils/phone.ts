/** 05551234567 → +905551234567 (backend E.164 formatı bekler) */
export function normalizePhoneNumber(value: string): string {
  const digits = value.replace(/\D/g, "");

  if (digits.startsWith("90") && digits.length === 12) {
    return `+${digits}`;
  }

  if (digits.startsWith("0") && digits.length === 11) {
    return `+90${digits.slice(1)}`;
  }

  if (digits.length === 10 && digits.startsWith("5")) {
    return `+90${digits}`;
  }

  if (value.startsWith("+")) {
    return `+${digits}`;
  }

  return value.trim();
}
