import { describe, it, expect } from "vitest";
import { ApiError, parseApiResponse } from "@/lib/api/envelope";

describe("parseApiResponse", () => {
  it("başarılı yanıtı parse eder", async () => {
    const body = {
      data: { id: "1", name: "Test" },
      isSuccess: true,
      message: "OK",
      code: 200,
      errors: null,
      timestamp: new Date().toISOString(),
    };

    const response = new Response(JSON.stringify(body), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });

    const result = await parseApiResponse<{ id: string; name: string }>(response);
    expect(result).toEqual({ id: "1", name: "Test" });
  });

  it("hata durumunda ApiError fırlatır", async () => {
    const body = {
      data: null,
      isSuccess: false,
      message: "Geçersiz istek",
      code: 400,
      errors: { email: ["Geçersiz e-posta"] },
      timestamp: new Date().toISOString(),
    };

    const response = new Response(JSON.stringify(body), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });

    await expect(parseApiResponse(response)).rejects.toThrow(ApiError);
  });
});
