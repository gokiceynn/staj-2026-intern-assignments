"use client";

import { usePathname } from "next/navigation";
import { RoleGate } from "@/components/auth/RoleGate";
import { PanelShell } from "@/components/layout/PanelShell";

const LINKS = [
  { href: "/admin", label: "Dashboard" },
  { href: "/admin/users", label: "Kullanıcılar" },
  { href: "/admin/sellers", label: "Satıcılar" },
  { href: "/admin/orders", label: "Siparişler" },
  { href: "/admin/carriers", label: "Kargo" },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <RoleGate roles={["Admin"]}>
      <PanelShell title="Admin Paneli" links={LINKS} activePath={pathname}>
        {children}
      </PanelShell>
    </RoleGate>
  );
}
