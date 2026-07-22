import type { ReactElement, SVGProps } from "react";

const ICONS: Record<string, (props: SVGProps<SVGSVGElement>) => ReactElement> = {
  devices: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <rect x="3" y="4" width="18" height="12" rx="2" stroke="currentColor" strokeWidth="1.8" />
      <path d="M8 20h8" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  ),
  checkroom: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <path d="M12 3l4 4v14H8V7l4-4Z" stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round" />
    </svg>
  ),
  chair: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <path d="M6 10h12v7H6v-7Zm2-4h8v4H8V6Z" stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round" />
    </svg>
  ),
  spa: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <path d="M12 3c2 3 4 4.5 4 7a4 4 0 1 1-8 0c0-2.5 2-4 4-7Z" stroke="currentColor" strokeWidth="1.8" />
    </svg>
  ),
  local_grocery_store: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <path d="M5 7h14l-1.2 9H6.2L5 7Zm2-3h10l1 3H6l1-3Z" stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round" />
    </svg>
  ),
  sports_soccer: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <circle cx="12" cy="12" r="8" stroke="currentColor" strokeWidth="1.8" />
      <path d="M12 4l2 4 4 1-2 3 1 4-5-2-5 2 1-4-2-3 4-1 2-4Z" stroke="currentColor" strokeWidth="1.2" />
    </svg>
  ),
  menu_book: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <path d="M5 4h7a3 3 0 0 1 3 3v13a3 3 0 0 0-3-3H5V4Zm14 0h-7a3 3 0 0 0-3 3v13a3 3 0 0 1 3-3h7V4Z" stroke="currentColor" strokeWidth="1.8" strokeLinejoin="round" />
    </svg>
  ),
  child_friendly: (props) => (
    <svg viewBox="0 0 24 24" fill="none" aria-hidden {...props}>
      <circle cx="12" cy="8" r="3" stroke="currentColor" strokeWidth="1.8" />
      <path d="M6 20c0-3.3 2.7-6 6-6s6 2.7 6 6" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  ),
};

export function CategoryIcon({
  iconKey,
  className,
}: {
  iconKey: string;
  className?: string;
}) {
  const Icon = ICONS[iconKey] ?? ICONS.devices!;
  return <Icon className={className} />;
}
