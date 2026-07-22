"use client";

import { usePathname } from "next/navigation";
import { RoleGate } from "@/components/auth/RoleGate";
import { PanelShell } from "@/components/layout/PanelShell";

const LINKS = [
  { href: "/seller", label: "Dashboard" },
  { href: "/seller/profile", label: "Profil" },
  { href: "/seller/products", label: "Ürünler" },
  { href: "/seller/orders", label: "Siparişler" },
];

export default function SellerLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <RoleGate roles={["Seller"]}>
      <PanelShell title="Satıcı Paneli" links={LINKS} activePath={pathname}>
        {children}
      </PanelShell>
    </RoleGate>
  );
}
