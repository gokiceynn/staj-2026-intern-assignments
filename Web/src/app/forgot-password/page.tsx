"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  forgotPasswordSchema,
  type ForgotPasswordInput,
} from "@/features/auth/schemas/auth";
import { useForgotPassword } from "@/features/auth/queries/use-auth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

export default function ForgotPasswordPage() {
  const router = useRouter();
  const forgotPassword = useForgotPassword();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<ForgotPasswordInput>({
    resolver: zodResolver(forgotPasswordSchema),
  });

  const onSubmit = async (data: ForgotPasswordInput) => {
    try {
      const session = await forgotPassword.mutateAsync(data);
      showToast("Sıfırlama kodu gönderildi", "success");
      router.push(
        `/reset-password?sessionId=${session.sessionId}&email=${encodeURIComponent(data.email)}`,
      );
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          setError(field as keyof ForgotPasswordInput, { message: messages[0] });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "İşlem başarısız",
          "error",
        );
      }
    }
  };

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-6 text-2xl font-bold">Şifremi Unuttum</h1>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <Input
          label="E-posta"
          type="email"
          error={errors.email?.message}
          {...register("email")}
        />
        <Button type="submit" className="w-full" loading={forgotPassword.isPending}>
          Kod Gönder
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
