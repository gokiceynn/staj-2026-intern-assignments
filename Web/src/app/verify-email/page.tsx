"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { verifyEmailSchema, type VerifyEmailInput } from "@/features/auth/schemas/auth";
import { useVerifyEmail } from "@/features/auth/queries/use-auth";
import { authApi } from "@/features/auth/api/auth-api";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";
import { getAuthErrorMessage } from "@/lib/api/auth-errors";

function VerifyEmailForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const verifyEmail = useVerifyEmail();
  const { showToast } = useToast();
  const [sessionId, setSessionId] = useState(
    () => searchParams.get("sessionId") ?? "",
  );
  const [resending, setResending] = useState(false);

  const email = searchParams.get("email") ?? "";

  const {
    register,
    handleSubmit,
    setError,
    setValue,
    formState: { errors },
  } = useForm<VerifyEmailInput>({
    resolver: zodResolver(verifyEmailSchema),
    defaultValues: { sessionId },
  });

  const handleResend = async () => {
    if (!email) {
      showToast("E-posta adresi bulunamadı.", "error");
      return;
    }

    setResending(true);
    try {
      const session = await authApi.resendEmail(email);
      setSessionId(session.sessionId);
      setValue("sessionId", session.sessionId);
      showToast("Yeni doğrulama kodu gönderildi.", "success");
    } catch (err) {
      showToast(
        getAuthErrorMessage(err, "Kod gönderilemedi. Mailpit (localhost:8026) adresine bakın."),
        "error",
      );
    } finally {
      setResending(false);
    }
  };

  const onSubmit = async (data: VerifyEmailInput) => {
    if (!data.sessionId) {
      showToast("Önce doğrulama kodu gönderin.", "error");
      return;
    }

    try {
      await verifyEmail.mutateAsync(data);
      showToast("E-posta doğrulandı, giriş yapıldı", "success");
      router.push("/");
      router.refresh();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof VerifyEmailInput, { message: messages[0] });
        }
      } else {
        showToast(getAuthErrorMessage(err, "Doğrulama başarısız"), "error");
      }
    }
  };

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-2 text-2xl font-bold">E-posta Doğrulama</h1>
      {email && (
        <p className="mb-6 text-sm text-text-muted">
          {email} adresine gönderilen kodu girin. Kod gelmediyse{" "}
          <a
            href="http://localhost:8026"
            target="_blank"
            rel="noreferrer"
            className="text-primary underline"
          >
            Mailpit
          </a>
          {" "}gelen kutusuna bakın.
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
        {email && (
          <Button
            type="button"
            variant="secondary"
            className="w-full"
            loading={resending}
            onClick={handleResend}
          >
            Yeni kod gönder
          </Button>
        )}
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
