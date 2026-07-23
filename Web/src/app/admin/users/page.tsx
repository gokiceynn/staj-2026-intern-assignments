"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { useAdminUsers } from "@/features/admin/queries/use-admin";
import { Badge } from "@/components/ui/Badge";
import { Pagination } from "@/components/ui/Pagination";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { formatDate } from "@/lib/utils/format";
import { ApiError } from "@/lib/api/envelope";

function UsersContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const { data, isLoading, error, refetch } = useAdminUsers({ page, size: 10 });

  if (isLoading) return <Skeleton className="h-64 w-full" />;

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Kullanıcılar yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  if (!data || data.items.length === 0) {
    return <EmptyState title="Kullanıcı bulunamadı" />;
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">Kullanıcılar</h2>
      <div className="overflow-x-auto rounded-lg border border-border">
        <table className="w-full text-sm">
          <thead className="border-b border-border bg-surface-muted">
            <tr>
              <th className="px-4 py-3 text-left font-medium">Ad Soyad</th>
              <th className="px-4 py-3 text-left font-medium">E-posta</th>
              <th className="px-4 py-3 text-left font-medium">Rol</th>
              <th className="px-4 py-3 text-left font-medium">Durum</th>
              <th className="px-4 py-3 text-left font-medium">Kayıt</th>
            </tr>
          </thead>
          <tbody>
            {data.items.map((user) => (
              <tr key={user.id} className="border-b border-border hover:bg-surface-muted">
                <td className="px-4 py-3">
                  <Link
                    href={`/admin/users/${user.id}`}
                    className="font-medium text-brand-600 hover:underline"
                  >
                    {user.fullName}
                  </Link>
                </td>
                <td className="px-4 py-3 text-text-muted">{user.email}</td>
                <td className="px-4 py-3">{user.role}</td>
                <td className="px-4 py-3">
                  <Badge variant={user.isActive ? "success" : "default"}>
                    {user.isActive ? "Aktif" : "Pasif"}
                  </Badge>
                </td>
                <td className="px-4 py-3 text-text-muted">
                  {formatDate(user.createdAt)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Pagination
        pageIndex={data.pageIndex}
        totalPages={data.totalPages}
        onPageChange={(p) => router.push(`/admin/users?page=${p}`)}
      />
    </div>
  );
}

export default function AdminUsersPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <UsersContent />
    </Suspense>
  );
}
