import { z } from "zod";

export const paymentCardSchema = z.object({
  cardHolderName: z.string().min(2, "Kart sahibi adı gerekli"),
  cardNumber: z
    .string()
    .min(16, "Kart numarası 16 haneli olmalı")
    .max(19)
    .regex(/^[\d\s]+$/, "Geçersiz kart numarası"),
  expireMonth: z.coerce.number().min(1).max(12),
  expireYear: z.coerce.number().min(new Date().getFullYear()),
  cvv: z.string().min(3, "CVV gerekli").max(4),
});

export const checkoutSchema = z.object({
  addressId: z.string().min(1, "Teslimat adresi seçin"),
  paymentCard: paymentCardSchema,
});

export const cancelOrderSchema = z.object({
  cancelReason: z.string().min(3, "İptal nedeni en az 3 karakter olmalı"),
});

export type PaymentCardInput = z.infer<typeof paymentCardSchema>;
export type CheckoutInput = z.infer<typeof checkoutSchema>;
export type CancelOrderInput = z.infer<typeof cancelOrderSchema>;
