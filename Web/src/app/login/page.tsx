"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { loginSchema, type LoginInput } from "@/features/auth/schemas/auth";
import { useLogin } from "@/features/auth/queries/use-auth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const login = useLogin();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<LoginInput>({ resolver: zodResolver(loginSchema) });

  const onSubmit = async (data: LoginInput) => {
    try {
      await login.mutateAsync(data);
      showToast("Giriş başarılı", "success");
      const redirect = searchParams.get("redirect") ?? "/";
      router.push(redirect);
      router.refresh();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof LoginInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Giriş başarısız",
          "error",
        );
      }
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
