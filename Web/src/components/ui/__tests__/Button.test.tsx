import { describe, it, expect, vi, afterEach } from "vitest";
import { render, screen, fireEvent, cleanup } from "@testing-library/react";
import { Button } from "@/components/ui/Button";

afterEach(() => {
  cleanup();
});

describe("Button", () => {
  it("metni render eder", () => {
    render(<Button>Test Butonu</Button>);
    expect(screen.getByRole("button", { name: "Test Butonu" })).toBeInTheDocument();
  });

  it("tıklama olayını tetikler", () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>Tıkla</Button>);
    fireEvent.click(screen.getByRole("button", { name: "Tıkla" }));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it("loading durumunda disabled olur", () => {
    render(<Button loading>Yükleniyor</Button>);
    expect(screen.getByRole("button", { name: "Yükleniyor" })).toBeDisabled();
  });
});
