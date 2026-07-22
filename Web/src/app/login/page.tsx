"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { loginSchema, type LoginInput } from "@/features/auth/schemas/auth";
import { useLogin } from "@/features/auth/queries/use-auth";
import { authApi } from "@/features/auth/api/auth-api";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";
import {
  getAuthErrorMessage,
  isAuthErrorCode,
} from "@/lib/api/auth-errors";

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const login = useLogin();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    setError,
    watch,
    formState: { errors },
  } = useForm<LoginInput>({ resolver: zodResolver(loginSchema) });

  const emailValue = watch("email");

  const onSubmit = async (data: LoginInput) => {
    try {
      await login.mutateAsync(data);
      showToast("Giriş başarılı", "success");
      const redirect = searchParams.get("redirect") ?? "/";
      router.push(redirect);
      router.refresh();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      const isUnverified =
        isAuthErrorCode(err, "EMAIL_NOT_VERIFIED") ||
        (err instanceof ApiError &&
          err.message.toLowerCase().includes("verification"));

      const isRateLimited = isAuthErrorCode(err, "RATE_LIMITED");

      if (isRateLimited) {
        showToast(getAuthErrorMessage(err, "Giriş başarısız"), "error");
        return;
      }

      if (isUnverified) {
        try {
          const session = await authApi.resendEmail(data.email);
          showToast(
            "E-posta doğrulanmamış. Yeni kod gönderildi — doğrulama sayfasına yönlendiriliyorsunuz.",
            "error",
          );
          router.push(
            `/verify-email?sessionId=${session.sessionId}&email=${encodeURIComponent(data.email)}`,
          );
          return;
        } catch (resendErr) {
          const cooldown =
            resendErr instanceof ApiError &&
            Boolean(resendErr.errors?.OTP_COOLDOWN);

          showToast(
            cooldown
              ? "E-posta doğrulanmamış. Az önce kod gönderilmiş olabilir — Mailpit (localhost:8026) adresine bakın."
              : "E-posta doğrulanmamış. Doğrulama sayfasından yeni kod isteyebilirsiniz.",
            "error",
          );
          router.push(
            `/verify-email?email=${encodeURIComponent(data.email)}`,
          );
          return;
        }
      }

      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          if (field in data) {
            setError(field as keyof LoginInput, { message: messages[0] });
          }
        }
      }

      showToast(getAuthErrorMessage(err, "Giriş başarısız"), "error");
    }
  };

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-6 text-2xl font-bold">Giriş Yap</h1>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <Input
          label="E-posta"
          type="email"
          error={errors.email?.message}
          {...register("email")}
        />
        <Input
          label="Şifre"
          type="password"
          error={errors.password?.message}
          {...register("password")}
        />
        <div className="flex justify-between text-sm">
          <Link href="/forgot-password" className="text-brand-600 hover:underline">
            Şifremi unuttum
          </Link>
          <Link
            href={
              emailValue
                ? `/verify-email?email=${encodeURIComponent(emailValue)}`
                : "/verify-email"
            }
            className="text-brand-600 hover:underline"
          >
            E-posta doğrula
          </Link>
        </div>
        <Button type="submit" className="w-full" loading={login.isPending}>
          Giriş Yap
        </Button>
      </form>
      <p className="mt-4 text-center text-sm text-text-muted">
        Hesabınız yok mu?{" "}
        <Link href="/register" className="text-brand-600 hover:underline">
          Kayıt olun
        </Link>
      </p>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense>
      <LoginForm />
    </Suspense>
  );
}
