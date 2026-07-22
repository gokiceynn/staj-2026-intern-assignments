"use client";

import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  updateProfileSchema,
  changePasswordSchema,
  type UpdateProfileInput,
  type ChangePasswordInput,
} from "@/features/auth/schemas/auth";
import {
  useProfile,
  useUpdateProfile,
  useChangePassword,
  useDeleteAccount,
  useStartEmailChange,
  useVerifyEmailChange,
} from "@/features/users/queries/use-users";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Skeleton } from "@/components/ui/Skeleton";
import { ErrorState } from "@/components/ui/ErrorState";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";
import { getAuthErrorMessage } from "@/lib/api/auth-errors";
import { useRouter } from "next/navigation";
import { useState } from "react";
import {
  changeEmailSchema,
  verifyEmailChangeSchema,
  type ChangeEmailInput,
  type VerifyEmailChangeInput,
} from "@/features/auth/schemas/auth";

export default function ProfilePage() {
  const router = useRouter();
  const { data: user, isLoading, error, refetch } = useProfile();
  const updateProfile = useUpdateProfile();
  const changePassword = useChangePassword();
  const deleteAccount = useDeleteAccount();
  const startEmailChange = useStartEmailChange();
  const verifyEmailChange = useVerifyEmailChange();
  const { showToast } = useToast();
  const [emailSessionId, setEmailSessionId] = useState("");

  const profileForm = useForm<UpdateProfileInput>({
    resolver: zodResolver(updateProfileSchema),
  });

  const passwordForm = useForm<ChangePasswordInput>({
    resolver: zodResolver(changePasswordSchema),
  });

  const emailForm = useForm<ChangeEmailInput>({
    resolver: zodResolver(changeEmailSchema),
  });

  const emailVerifyForm = useForm<VerifyEmailChangeInput>({
    resolver: zodResolver(verifyEmailChangeSchema),
    defaultValues: { sessionId: "" },
  });

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !user) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Profil yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  const onProfileSubmit = async (data: UpdateProfileInput) => {
    try {
      await updateProfile.mutateAsync(data);
      showToast("Profil güncellendi", "success");
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          profileForm.setError(field as keyof UpdateProfileInput, {
            message: messages[0],
          });
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Güncelleme başarısız",
          "error",
        );
      }
    }
  };

  const onPasswordSubmit = async (data: ChangePasswordInput) => {
    try {
      await changePassword.mutateAsync(data);
      showToast("Şifre değiştirildi", "success");
      passwordForm.reset();
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          passwordForm.setError(field as keyof ChangePasswordInput, {
            message: messages[0],
          });
        }
      } else {
        showToast(getAuthErrorMessage(err, "Şifre değiştirilemedi"), "error");
      }
    }
  };

  const onEmailSubmit = async (data: ChangeEmailInput) => {
    try {
      const session = await startEmailChange.mutateAsync(data);
      setEmailSessionId(session.sessionId);
      emailVerifyForm.setValue("sessionId", session.sessionId);
      showToast("Doğrulama kodu yeni e-posta adresinize gönderildi", "success");
    } catch (err) {
      showToast(getAuthErrorMessage(err, "E-posta değiştirilemedi"), "error");
    }
  };

  const onEmailVerifySubmit = async (data: VerifyEmailChangeInput) => {
    try {
      await verifyEmailChange.mutateAsync(data);
      showToast("E-posta güncellendi", "success");
      setEmailSessionId("");
      emailForm.reset();
      emailVerifyForm.reset();
      refetch();
    } catch (err) {
      showToast(getAuthErrorMessage(err, "Doğrulama başarısız"), "error");
    }
  };

  const onDeleteAccount = async () => {
    const password = window.prompt("Hesabınızı silmek için şifrenizi girin:");
    if (!password) return;
    try {
      await deleteAccount.mutateAsync(password);
      showToast("Hesap silindi", "success");
      router.push("/");
      router.refresh();
    } catch (err) {
      showToast(getAuthErrorMessage(err, "Hesap silinemedi"), "error");
    }
  };

  return (
    <div className="mx-auto max-w-2xl space-y-8">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Profilim</h1>
        <Link href="/profile/addresses" className="text-sm text-brand-600 hover:underline">
          Adreslerim
        </Link>
      </div>

      <form
        onSubmit={profileForm.handleSubmit(onProfileSubmit)}
        className="space-y-4 rounded-lg border border-border bg-surface p-6"
      >
        <h2 className="text-lg font-semibold">Kişisel Bilgiler</h2>
        <p className="text-sm text-text-muted">{user.email}</p>
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="Ad"
            defaultValue={user.firstName}
            error={profileForm.formState.errors.firstName?.message}
            {...profileForm.register("firstName")}
          />
          <Input
            label="Soyad"
            defaultValue={user.lastName}
            error={profileForm.formState.errors.lastName?.message}
            {...profileForm.register("lastName")}
          />
        </div>
        <Input
          label="Telefon"
          defaultValue={user.phoneNumber}
          error={profileForm.formState.errors.phoneNumber?.message}
          {...profileForm.register("phoneNumber")}
        />
        <Button type="submit" loading={updateProfile.isPending}>
          Kaydet
        </Button>
      </form>

      <form
        onSubmit={emailForm.handleSubmit(onEmailSubmit)}
        className="space-y-4 rounded-lg border border-border bg-surface p-6"
      >
        <h2 className="text-lg font-semibold">E-posta Değiştir</h2>
        <p className="text-sm text-text-muted">Mevcut: {user.email}</p>
        <Input
          label="Yeni E-posta"
          type="email"
          error={emailForm.formState.errors.newEmail?.message}
          {...emailForm.register("newEmail")}
        />
        <Input
          label="Şifre"
          type="password"
          error={emailForm.formState.errors.password?.message}
          {...emailForm.register("password")}
        />
        <Button type="submit" loading={startEmailChange.isPending}>
          Kod Gönder
        </Button>
      </form>

      {emailSessionId && (
        <form
          onSubmit={emailVerifyForm.handleSubmit(onEmailVerifySubmit)}
          className="space-y-4 rounded-lg border border-border bg-surface p-6"
        >
          <h2 className="text-lg font-semibold">E-posta Doğrulama Kodu</h2>
          <input type="hidden" {...emailVerifyForm.register("sessionId")} />
          <Input
            label="Doğrulama Kodu"
            error={emailVerifyForm.formState.errors.code?.message}
            {...emailVerifyForm.register("code")}
          />
          <Button type="submit" loading={verifyEmailChange.isPending}>
            E-postayı Doğrula
          </Button>
        </form>
      )}

      <form
        onSubmit={passwordForm.handleSubmit(onPasswordSubmit)}
        className="space-y-4 rounded-lg border border-border bg-surface p-6"
      >
        <h2 className="text-lg font-semibold">Şifre Değiştir</h2>
        <Input
          label="Mevcut Şifre"
          type="password"
          error={passwordForm.formState.errors.currentPassword?.message}
          {...passwordForm.register("currentPassword")}
        />
        <Input
          label="Yeni Şifre"
          type="password"
          error={passwordForm.formState.errors.newPassword?.message}
          {...passwordForm.register("newPassword")}
        />
        <Input
          label="Yeni Şifre Tekrar"
          type="password"
          error={passwordForm.formState.errors.newPasswordConfirm?.message}
          {...passwordForm.register("newPasswordConfirm")}
        />
        <Button type="submit" loading={changePassword.isPending}>
          Şifreyi Değiştir
        </Button>
      </form>

      <div className="rounded-lg border border-danger/30 bg-surface p-6">
        <h2 className="text-lg font-semibold text-danger">Tehlikeli Bölge</h2>
        <p className="mb-4 text-sm text-text-muted">
          Hesabınızı kalıcı olarak silebilirsiniz. Bu işlem geri alınamaz.
        </p>
        <Button
          variant="danger"
          loading={deleteAccount.isPending}
          onClick={onDeleteAccount}
        >
          Hesabımı Sil
        </Button>
      </div>
    </div>
  );
}
