import { describe, it, expect } from "vitest";
import { formatCurrency, formatDate } from "@/lib/utils/format";

describe("formatCurrency", () => {
  it("TRY formatında para birimi döner", () => {
    const result = formatCurrency(99.9);
    expect(result).toContain("99");
    expect(result).toContain("₺");
  });
});

describe("formatDate", () => {
  it("tarih formatlar", () => {
    const result = formatDate("2025-01-15T10:30:00Z");
    expect(result).toBeTruthy();
    expect(typeof result).toBe("string");
  });

  it("geçersiz veya boş değerde fallback döner", () => {
    expect(formatDate(undefined)).toBe("—");
    expect(formatDate("")).toBe("—");
    expect(formatDate("invalid")).toBe("—");
  });
});
