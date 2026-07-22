"use client";

import { Badge } from "@/components/ui/Badge";
import { useOrderStatusLabel } from "@/features/metadata/queries/use-metadata";

type OrderStatusBadgeProps = {
  status: string;
};

export function OrderStatusBadge({ status }: OrderStatusBadgeProps) {
  const label = useOrderStatusLabel(status);
  return <Badge>{label}</Badge>;
}
