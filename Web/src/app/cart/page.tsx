"use client";

import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  useCart,
  useUpdateCartItem,
  useRemoveCartItem,
  useClearCart,
} from "@/features/cart/queries/use-cart";
import { Price } from "@/components/ui/Price";
import { QuantitySelector } from "@/components/ui/QuantitySelector";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError } from "@/lib/api/envelope";

export default function CartPage() {
  const router = useRouter();
  const { data: cart, isLoading, error, refetch } = useCart();
  const updateItem = useUpdateCartItem();
  const removeItem = useRemoveCartItem();
  const clearCart = useClearCart();
  const { showToast } = useToast();

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-48" />
        {Array.from({ length: 3 }).map((_, i) => (
          <Skeleton key={i} className="h-24 w-full" />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <ErrorState
        message={error instanceof ApiError ? error.message : "Sepet yüklenemedi"}
        onRetry={() => refetch()}
      />
    );
  }

  if (!cart || cart.items.length === 0) {
    return (
      <EmptyState
        title="Sepetiniz boş"
        description="Alışverişe başlamak için ürünlere göz atın."
        action={
          <Button onClick={() => router.push("/products")}>Ürünlere Git</Button>
        }
      />
    );
  }

  const handleQuantityChange = async (productId: string, quantity: number) => {
    try {
      await updateItem.mutateAsync({ productId, input: { quantity } });
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Güncellenemedi",
        "error",
      );
    }
  };

  const handleRemove = async (productId: string) => {
    try {
      await removeItem.mutateAsync(productId);
      showToast("Ürün sepetten kaldırıldı", "success");
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Ürün kaldırılamadı",
        "error",
      );
    }
  };

  const handleClearCart = async () => {
    try {
      await clearCart.mutateAsync();
      showToast("Sepet temizlendi", "success");
    } catch (err) {
      showToast(
        err instanceof ApiError ? err.message : "Sepet temizlenemedi",
        "error",
      );
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Sepetim</h1>
        <Button
          variant="ghost"
          size="sm"
          onClick={handleClearCart}
          loading={clearCart.isPending}
        >
          Sepeti Temizle
        </Button>
      </div>

      <div className="space-y-4">
        {cart.items.map((item) => (
          <div
            key={item.productId}
            className="flex gap-4 rounded-lg border border-border bg-surface p-4"
          >
            <div className="relative h-20 w-20 shrink-0 overflow-hidden rounded-md">
              <Image
                src={item.photoUrl}
                alt={item.productTitle}
                fill
                className="object-cover"
                sizes="80px"
              />
            </div>
            <div className="flex flex-1 flex-col gap-2">
              <Link
                href={`/products/${item.productId}`}
                className="font-medium hover:text-brand-600"
              >
                {item.productTitle}
              </Link>
              <Price amount={item.price} size="sm" />
              <div className="flex flex-wrap items-center gap-4">
                <QuantitySelector
                  value={item.quantity}
                  onChange={(q) => handleQuantityChange(item.productId, q)}
                  disabled={updateItem.isPending}
                />
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => handleRemove(item.productId)}
                  loading={removeItem.isPending}
                >
                  Kaldır
                </Button>
              </div>
            </div>
            <div className="text-right">
              <Price amount={item.totalPrice} />
            </div>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between rounded-lg border border-border bg-surface p-4">
        <span className="text-lg font-semibold">Toplam</span>
        <Price amount={cart.totalAmount} size="lg" />
      </div>

      <Button size="lg" onClick={() => router.push("/checkout")}>
        Ödemeye Geç
      </Button>
    </div>
  );
}
