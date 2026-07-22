import Link from "next/link";
import { cn } from "@/lib/utils/cn";

type PanelLink = { href: string; label: string };

type PanelShellProps = {
  title: string;
  links: PanelLink[];
  activePath: string;
  children: React.ReactNode;
};

export function PanelShell({
  title,
  links,
  activePath,
  children,
}: PanelShellProps) {
  return (
    <div className="mx-auto flex max-w-7xl flex-col gap-6 px-4 py-6 md:flex-row">
      <aside className="w-full shrink-0 md:w-56">
        <h1 className="mb-4 text-xl font-bold">{title}</h1>
        <nav className="flex flex-row gap-2 overflow-x-auto md:flex-col md:gap-1">
          {links.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={cn(
                "whitespace-nowrap rounded-lg px-3 py-2 text-sm font-medium transition",
                activePath.startsWith(link.href)
                  ? "bg-brand-500 text-white"
                  : "text-text-muted hover:bg-surface-muted hover:text-text",
              )}
            >
              {link.label}
            </Link>
          ))}
        </nav>
        <Link
          href="/"
          className="mt-4 inline-block text-sm text-brand-600 hover:underline"
        >
          ← Mağazaya dön
        </Link>
      </aside>
      <main className="min-w-0 flex-1">{children}</main>
    </div>
  );
}
