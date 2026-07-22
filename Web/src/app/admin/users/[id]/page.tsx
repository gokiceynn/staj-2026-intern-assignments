"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useAdminUser } from "@/features/admin/queries/use-admin";
import { Badge } from "@/components/ui/Badge";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

export default function AdminUserDetailPage() {
  const params = useParams<{ id: string }>();
  const { data: user, isLoading, error, refetch } = useAdminUser(params.id);

  if (isLoading) return <Skeleton className="h-96 w-full" />;

  if (error || !user) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Kullanıcı bulunamadı"}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <Link href="/admin/users" className="text-sm text-brand-600 hover:underline">
        ← Kullanıcılar
      </Link>
      <h2 className="text-xl font-semibold">{user.fullName}</h2>

      <div className="space-y-3 rounded-lg border border-border bg-surface p-6 text-sm">
        <div className="flex justify-between">
          <span className="text-text-muted">E-posta</span>
          <span>{user.email}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Telefon</span>
          <span>{user.phoneNumber}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Rol</span>
          <span>{user.role}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Durum</span>
          <Badge variant={user.isActive ? "success" : "default"}>
            {user.isActive ? "Aktif" : "Pasif"}
          </Badge>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">E-posta Doğrulandı</span>
          <span>{user.isEmailVerified ? "Evet" : "Hayır"}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-text-muted">Kayıt Tarihi</span>
          <span>{formatDate(user.createdAt)}</span>
        </div>
        {user.lastLoginAt && (
          <div className="flex justify-between">
            <span className="text-text-muted">Son Giriş</span>
            <span>{formatDate(user.lastLoginAt)}</span>
          </div>
        )}
      </div>
    </div>
  );
}
