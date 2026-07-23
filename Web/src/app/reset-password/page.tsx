"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  resetPasswordSchema,
  type ResetPasswordInput,
} from "@/features/auth/schemas/auth";
import { useResetPassword } from "@/features/auth/queries/use-auth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const resetPassword = useResetPassword();
  const { showToast } = useToast();

  const sessionId = searchParams.get("sessionId") ?? "";
  const email = searchParams.get("email") ?? "";

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<ResetPasswordInput>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { sessionId },
  });

  const onSubmit = async (data: ResetPasswordInput) => {
    try {
      await resetPassword.mutateAsync(data);
      showToast("Şifre sıfırlandı", "success");
      router.push("/login");
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof ResetPasswordInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Sıfırlama başarısız",
          "error",
        );
      }
    }
  };

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-2 text-2xl font-bold">Şifre Sıfırla</h1>
      {email && (
        <p className="mb-6 text-sm text-text-muted">{email}</p>
      )}
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <input type="hidden" {...register("sessionId")} />
        <Input
          label="Doğrulama Kodu"
          error={errors.code?.message}
          {...register("code")}
        />
        <Input
          label="Yeni Şifre"
          type="password"
          error={errors.newPassword?.message}
          {...register("newPassword")}
        />
        <Input
          label="Yeni Şifre Tekrar"
          type="password"
          error={errors.newPasswordConfirm?.message}
          {...register("newPasswordConfirm")}
        />
        <Button type="submit" className="w-full" loading={resetPassword.isPending}>
          Şifreyi Sıfırla
        </Button>
      </form>
      <p className="mt-4 text-center text-sm">
        <Link href="/login" className="text-brand-600 hover:underline">
          Giriş sayfasına dön
        </Link>
      </p>
    </div>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense>
      <ResetPasswordForm />
    </Suspense>
  );
}
