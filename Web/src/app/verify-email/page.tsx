"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { verifyEmailSchema, type VerifyEmailInput } from "@/features/auth/schemas/auth";
import { useVerifyEmail } from "@/features/auth/queries/use-auth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

function VerifyEmailForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const verifyEmail = useVerifyEmail();
  const { showToast } = useToast();

  const sessionId = searchParams.get("sessionId") ?? "";
  const email = searchParams.get("email") ?? "";

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<VerifyEmailInput>({
    resolver: zodResolver(verifyEmailSchema),
    defaultValues: { sessionId },
  });

  const onSubmit = async (data: VerifyEmailInput) => {
    try {
      await verifyEmail.mutateAsync(data);
      showToast("E-posta doğrulandı", "success");
      router.push("/");
      router.refresh();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof VerifyEmailInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Doğrulama başarısız",
          "error",
        );
      }
    }
  };

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-2 text-2xl font-bold">E-posta Doğrulama</h1>
      {email && (
        <p className="mb-6 text-sm text-text-muted">
          {email} adresine gönderilen kodu girin.
        </p>
      )}
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <input type="hidden" {...register("sessionId")} />
        <Input
          label="Doğrulama Kodu"
          error={errors.code?.message}
          {...register("code")}
        />
        <Button type="submit" className="w-full" loading={verifyEmail.isPending}>
          Doğrula
        </Button>
      </form>
    </div>
  );
}

export default function VerifyEmailPage() {
  return (
    <Suspense>
      <VerifyEmailForm />
    </Suspense>
  );
}
