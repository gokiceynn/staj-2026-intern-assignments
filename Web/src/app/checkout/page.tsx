"use client";

import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { checkoutSchema, type CheckoutInput } from "@/features/orders/schemas/order";
import { useCheckout } from "@/features/orders/queries/use-orders";
import { useCart } from "@/features/cart/queries/use-cart";
import { useAddresses } from "@/features/addresses/queries/use-addresses";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { Button } from "@/components/ui/Button";
import { Price } from "@/components/ui/Price";
import { ErrorState } from "@/components/ui/ErrorState";
import { Skeleton } from "@/components/ui/Skeleton";
import { useToast } from "@/components/ui/toast-context";
import { ApiError, getFieldErrors } from "@/lib/api/envelope";
import Link from "next/link";

export default function CheckoutPage() {
  const router = useRouter();
  const { data: cart, isLoading: cartLoading } = useCart();
  const { data: addresses, isLoading: addrLoading } = useAddresses();
  const checkout = useCheckout();
  const { showToast } = useToast();

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<CheckoutInput>({
    resolver: zodResolver(checkoutSchema),
    defaultValues: {
      paymentCard: {
        expireMonth: 12,
        expireYear: new Date().getFullYear() + 1,
      },
    },
  });

  if (cartLoading || addrLoading) {
    return <Skeleton className="h-96 w-full" />;
  }

  if (!cart || cart.items.length === 0) {
    return (
      <ErrorState
        message="Sepetiniz boş. Ödeme yapılamaz."
        onRetry={() => router.push("/cart")}
      />
    );
  }

  const onSubmit = async (data: CheckoutInput) => {
    try {
      const order = await checkout.mutateAsync(data);
      showToast("Sipariş oluşturuldu", "success");
      router.push(`/order-success/${order.orderId}`);
    } catch (err) {
      const fieldErrors = getFieldErrors(err);
      if (fieldErrors) {
        for (const [field, messages] of Object.entries(fieldErrors)) {
          const parts = field.split(".");
          if (parts[0] === "paymentCard" && parts[1]) {
            setError(`paymentCard.${parts[1]}` as keyof CheckoutInput, {
              message: messages[0],
            });
          } else {
            setError(field as keyof CheckoutInput, { message: messages[0] });
          }
        }
      } else {
        showToast(
          err instanceof ApiError ? err.message : "Ödeme başarısız",
          "error",
        );
      }
    }
  };

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <h1 className="text-2xl font-bold">Ödeme</h1>

      <div className="rounded-lg border border-border bg-surface p-4">
        <p className="text-sm text-text-muted">Sipariş Toplamı</p>
        <Price amount={cart.totalAmount} size="lg" />
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        <fieldset className="space-y-4">
          <legend className="text-lg font-semibold">Teslimat Adresi</legend>
          {addresses && addresses.length > 0 ? (
            <Select
              label="Adres Seçin"
              error={errors.addressId?.message}
              options={[
                { value: "", label: "Seçin..." },
                ...addresses.map((a) => ({
                  value: a.id,
                  label: `${a.title} — ${a.city}`,
                })),
              ]}
              {...register("addressId")}
            />
          ) : (
            <p className="text-sm text-text-muted">
              Kayıtlı adres yok.{" "}
              <Link href="/profile/addresses" className="text-brand-600 hover:underline">
                Adres ekleyin
              </Link>
            </p>
          )}
        </fieldset>

        <fieldset className="space-y-4">
          <legend className="text-lg font-semibold">Ödeme Kartı</legend>
          <Input
            label="Kart Sahibi"
            error={errors.paymentCard?.cardHolderName?.message}
            {...register("paymentCard.cardHolderName")}
          />
          <Input
            label="Kart Numarası"
            error={errors.paymentCard?.cardNumber?.message}
            {...register("paymentCard.cardNumber")}
          />
          <div className="grid grid-cols-3 gap-4">
            <Input
              label="Ay"
              type="number"
              error={errors.paymentCard?.expireMonth?.message}
              {...register("paymentCard.expireMonth")}
            />
            <Input
              label="Yıl"
              type="number"
              error={errors.paymentCard?.expireYear?.message}
              {...register("paymentCard.expireYear")}
            />
            <Input
              label="CVV"
              error={errors.paymentCard?.cvv?.message}
              {...register("paymentCard.cvv")}
            />
          </div>
        </fieldset>

        <Button type="submit" size="lg" className="w-full" loading={checkout.isPending}>
          Siparişi Tamamla
        </Button>
      </form>
    </div>
  );
}
