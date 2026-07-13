import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/utils/cn";

type ErrorStateProps = {
  title?: string;
  message: string;
  onRetry?: () => void;
  className?: string;
};

export function ErrorState({
  title = "Bir hata oluştu",
  message,
  onRetry,
  className,
}: ErrorStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center rounded-lg border border-danger/30 bg-red-50 p-8 text-center dark:bg-red-950/30",
        className,
      )}
      role="alert"
    >
      <h3 className="text-lg font-semibold text-danger">{title}</h3>
      <p className="mt-2 text-sm text-text-muted">{message}</p>
      {onRetry && (
        <Button variant="outline" className="mt-4" onClick={onRetry}>
          Tekrar Dene
        </Button>
      )}
    </div>
  );
}
