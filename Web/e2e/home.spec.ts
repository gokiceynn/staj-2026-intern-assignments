import { test, expect } from "@playwright/test";

test.describe("Ana sayfa", () => {
  test("başlık ve navigasyon görünür", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("link", { name: "VBShop" })).toBeVisible();
    await expect(page.getByText("VBShop'a Hoş Geldiniz")).toBeVisible();
  });

  test("ürünler sayfasına gidebilir", async ({ page }) => {
    await page.goto("/");
    await page.getByRole("link", { name: "Alışverişe Başla" }).click();
    await expect(page).toHaveURL(/\/products/);
    await expect(page.getByRole("heading", { name: "Ürünler" })).toBeVisible();
  });

  test("giriş sayfasına gidebilir", async ({ page }) => {
    await page.goto("/login");
    await expect(page.getByRole("heading", { name: "Giriş Yap" })).toBeVisible();
  });
});
