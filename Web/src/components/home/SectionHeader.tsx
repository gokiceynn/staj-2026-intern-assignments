import Link from "next/link";

type SectionHeaderProps = {
  title: string;
  href?: string;
  seeAllLabel?: string;
};

export function SectionHeader({
  title,
  href,
  seeAllLabel = "Tümünü Gör",
}: SectionHeaderProps) {
  return (
    <div className="flex items-center justify-between px-4 pt-2">
      <h2 className="text-base font-bold text-text md:text-lg">{title}</h2>
      {href && (
        <Link
          href={href}
          className="text-sm font-medium text-brand-600 hover:underline"
        >
          {seeAllLabel}
        </Link>
      )}
    </div>
  );
}
