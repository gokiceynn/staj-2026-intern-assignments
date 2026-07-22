"use client";

import { useRouter } from "next/navigation";
import { useCurrentUser } from "@/features/auth/queries/use-auth";
import { Skeleton } from "@/components/ui/Skeleton";
import { ErrorState } from "@/components/ui/ErrorState";
import type { UserRole } from "@/types/api";

type RoleGateProps = {
  roles: UserRole[];
  children: React.ReactNode;
};

export function RoleGate({ roles, children }: RoleGateProps) {
  const router = useRouter();
  const { data: user, isLoading, error } = useCurrentUser();

  if (isLoading) {
    return <Skeleton className="h-64 w-full" />;
  }

  if (error || !user) {
    router.replace("/login");
    return null;
  }

  if (!roles.includes(user.role)) {
    return (
      <ErrorState message="Bu sayfaya erişim yetkiniz yok." />
    );
  }

  return <>{children}</>;
}
