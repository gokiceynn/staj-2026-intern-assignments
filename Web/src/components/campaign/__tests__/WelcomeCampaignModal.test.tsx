import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent, cleanup, waitFor } from "@testing-library/react";
import { WelcomeCampaignModal } from "@/components/campaign/WelcomeCampaignModal";

const useCurrentUserMock = vi.fn();

vi.mock("@/features/auth/queries/use-auth", () => ({
  useCurrentUser: () => useCurrentUserMock(),
}));

vi.mock("next/image", () => ({
  default: ({
    src,
    alt,
    ...props
  }: {
    src: string;
    alt: string;
    priority?: boolean;
    sizes?: string;
    width?: number;
    height?: number;
    className?: string;
  }) => (
    // eslint-disable-next-line @next/next/no-img-element
    <img src={src} alt={alt} {...props} />
  ),
}));

describe("WelcomeCampaignModal", () => {
  beforeEach(() => {
    useCurrentUserMock.mockReturnValue({
      data: null,
      isPending: false,
    });
  });

  afterEach(() => {
    cleanup();
    vi.clearAllMocks();
  });

  it("giriş yapmamış kullanıcıya modalı gösterir", async () => {
    render(<WelcomeCampaignModal />);

    expect(
      await screen.findByRole("dialog", { name: "VBShop karşılama kampanyası" }),
    ).toBeInTheDocument();
    expect(screen.getByAltText(/VBShop kampanya/i)).toBeInTheDocument();
  });

  it("giriş yapmış kullanıcıya modalı göstermez", async () => {
    useCurrentUserMock.mockReturnValue({
      data: { id: "user-1", email: "test@example.com" },
      isPending: false,
    });

    render(<WelcomeCampaignModal />);

    await waitFor(() => {
      expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    });
  });

  it("auth yüklenirken modalı göstermez", () => {
    useCurrentUserMock.mockReturnValue({
      data: null,
      isPending: true,
    });

    render(<WelcomeCampaignModal />);

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("kapatınca kaybolur, sayfa yenilenince tekrar görünür", async () => {
    const { unmount } = render(<WelcomeCampaignModal />);

    fireEvent.click(await screen.findByRole("button", { name: "Kampanyayı kapat" }));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

    unmount();
    render(<WelcomeCampaignModal />);

    expect(
      await screen.findByRole("dialog", { name: "VBShop karşılama kampanyası" }),
    ).toBeInTheDocument();
  });

  it("kayıt alanı /register sayfasına gider ve modalı kapatır", async () => {
    render(<WelcomeCampaignModal />);

    const registerLink = await screen.findByRole("link", {
      name: "Yeni üyelik için kayıt ol",
    });

    expect(registerLink).toHaveAttribute("href", "/register");

    fireEvent.click(registerLink);

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("Escape tuşu ile kapanır", async () => {
    render(<WelcomeCampaignModal />);

    await screen.findByRole("dialog");
    fireEvent.keyDown(document, { key: "Escape" });

    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("kayıt alanı klavye ile odaklanabilir", async () => {
    render(<WelcomeCampaignModal />);

    const registerLink = await screen.findByRole("link", {
      name: "Yeni üyelik için kayıt ol",
    });

    registerLink.focus();
    expect(registerLink).toHaveFocus();
  });
});
