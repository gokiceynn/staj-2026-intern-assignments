"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { registerSchema, type RegisterInput } from "@/features/auth/schemas/auth";
import { useRegister } from "@/features/auth/queries/use-auth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";

export default function RegisterPage() {
  const router = useRouter();
  const registerMutation = useRegister();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<RegisterInput>({ resolver: zodResolver(registerSchema) });

  const onSubmit = async (data: RegisterInput) => {
    try {
      const session = await registerMutation.mutateAsync(data);
      showToast("Doğrulama kodu gönderildi", "success");
      router.push(
        `/verify-email?sessionId=${session.sessionId}&email=${encodeURIComponent(data.email)}`,
      );
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      let shownOnField = false;

      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          if (field in data) {
            setError(field as keyof RegisterInput, { message: messages[0] });
            shownOnField = true;
          }
        }
      }

      const message =
        err instanceof ApiError
          ? err.code === 409
            ? "Bu e-posta adresi zaten kayıtlı. Giriş yapmayı veya e-posta doğrulamayı deneyin."
            : err.message
          : "Kayıt başarısız";

      if (!shownOnField || err instanceof ApiError) {
        showToast(message, "error");
      }
    }
  };

  const onInvalid = () => {
    showToast("Lütfen tüm alanları kontrol edin (şifre en az 12 karakter)", "error");
  };

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-6 text-2xl font-bold">Kayıt Ol</h1>
      <form onSubmit={handleSubmit(onSubmit, onInvalid)} className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Ad"
            error={errors.firstName?.message}
            {...register("firstName")}
          />
          <Input
            label="Soyad"
            error={errors.lastName?.message}
            {...register("lastName")}
          />
        </div>
        <Input
          label="E-posta"
          type="email"
          error={errors.email?.message}
          {...register("email")}
        />
        <Input
          label="Telefon"
          placeholder="0555 123 45 67"
          error={errors.phoneNumber?.message}
          {...register("phoneNumber")}
        />
        <Input
          label="Şifre"
          type="password"
          placeholder="En az 12 karakter"
          error={errors.password?.message}
          {...register("password")}
        />
        <p className="text-xs text-text-muted">
          Şifre en az 12 karakter; büyük harf, küçük harf ve rakam içermeli.
        </p>
        <Input
          label="Şifre Tekrar"
          type="password"
          error={errors.passwordConfirm?.message}
          {...register("passwordConfirm")}
        />
        <Button type="submit" className="w-full" loading={registerMutation.isPending}>
          Kayıt Ol
        </Button>
      </form>
      <p className="mt-4 text-center text-sm text-text-muted">
        Zaten hesabınız var mı?{" "}
        <Link href="/login" className="text-brand-600 hover:underline">
          Giriş yapın
        </Link>
        {" · "}
        <Link href="/register/seller" className="text-brand-600 hover:underline">
          Satıcı kaydı
        </Link>
      </p>
    </div>
  );
}
