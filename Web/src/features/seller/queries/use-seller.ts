"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  sellerApi,
  type SellerProductWriteInput,
} from "@/features/seller/api/seller-api";
import { queryKeys } from "@/lib/query/keys";
import { useCurrentUser } from "@/features/auth/queries/use-auth";

export function useSellerProfile() {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.profile,
    queryFn: () => sellerApi.getProfile(),
    enabled: user?.role === "Seller",
    staleTime: 60_000,
  });
}

export function useUpdateSellerProfile() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: sellerApi.updateProfile,
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.seller.profile, data);
    },
  });
}

export function useSellerDashboard(params?: { from?: string; to?: string }) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.dashboard(params ?? {}),
    queryFn: () => sellerApi.getDashboard(params),
    enabled: user?.role === "Seller",
    staleTime: 30_000,
  });
}

export function useSellerProducts(params?: {
  page?: number;
  size?: number;
  q?: string;
  isActive?: boolean;
}) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.products(params ?? {}),
    queryFn: () => sellerApi.listProducts(params),
    enabled: user?.role === "Seller",
    staleTime: 10_000,
  });
}

export function useSellerProduct(id: string) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.product(id),
    queryFn: () => sellerApi.getProduct(id),
    enabled: user?.role === "Seller" && Boolean(id),
  });
}

export function useCreateSellerProduct() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: SellerProductWriteInput) => sellerApi.createProduct(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["seller", "products"] });
      queryClient.invalidateQueries({ queryKey: ["seller", "dashboard"] });
    },
  });
}

export function useUpdateSellerProduct() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      input,
    }: {
      id: string;
      input: SellerProductWriteInput;
    }) => sellerApi.updateProduct(id, input),
    onSuccess: (data, { id }) => {
      queryClient.setQueryData(queryKeys.seller.product(id), data);
      queryClient.invalidateQueries({ queryKey: ["seller", "products"] });
    },
  });
}

export function useDeleteSellerProduct() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => sellerApi.deleteProduct(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["seller", "products"] });
      queryClient.invalidateQueries({ queryKey: ["seller", "dashboard"] });
    },
  });
}

export function useSellerCarriers() {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.carriers,
    queryFn: () => sellerApi.listCarriers(),
    enabled: user?.role === "Seller",
    staleTime: 300_000,
  });
}

export function useSellerOrders(params?: {
  page?: number;
  size?: number;
  status?: string;
  from?: string;
  to?: string;
}) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.orders(params ?? {}),
    queryFn: () => sellerApi.listOrders(params),
    enabled: user?.role === "Seller",
    staleTime: 10_000,
  });
}

export function useSellerOrder(packageId: string) {
  const { data: user } = useCurrentUser();

  return useQuery({
    queryKey: queryKeys.seller.order(packageId),
    queryFn: () => sellerApi.getOrder(packageId),
    enabled: user?.role === "Seller" && Boolean(packageId),
  });
}

export function usePrepareSellerOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (packageId: string) => sellerApi.prepareOrder(packageId),
    onSuccess: (_, packageId) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.seller.order(packageId) });
      queryClient.invalidateQueries({ queryKey: ["seller", "orders"] });
      queryClient.invalidateQueries({ queryKey: ["seller", "dashboard"] });
    },
  });
}

export function useShipSellerOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      packageId,
      input,
    }: {
      packageId: string;
      input: { carrierId: string; trackingNumber: string };
    }) => sellerApi.shipOrder(packageId, input),
    onSuccess: (_, { packageId }) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.seller.order(packageId) });
      queryClient.invalidateQueries({ queryKey: ["seller", "orders"] });
      queryClient.invalidateQueries({ queryKey: ["seller", "dashboard"] });
    },
  });
}

export function useDeliverSellerOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (packageId: string) => sellerApi.deliverOrder(packageId),
    onSuccess: (_, packageId) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.seller.order(packageId) });
      queryClient.invalidateQueries({ queryKey: ["seller", "orders"] });
      queryClient.invalidateQueries({ queryKey: ["seller", "dashboard"] });
    },
  });
}
