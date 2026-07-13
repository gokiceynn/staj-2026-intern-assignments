import { apiClient } from "@/lib/api/client";
import type {
  OrderDetail,
  OrderSummary,
  Paginated,
  PaymentCard,
} from "@/types/api";
import type {
  CancelOrderInput,
  CheckoutInput,
} from "@/features/orders/schemas/order";

export const ordersApi = {
  list: (params?: { page?: number; size?: number }) =>
    apiClient<Paginated<OrderSummary>>("orders", { params }),

  getById: (id: string) => apiClient<OrderDetail>(`orders/${id}`),

  checkout: (input: CheckoutInput) =>
    apiClient<OrderDetail>("orders/checkout", {
      method: "POST",
      body: input,
    }),

  cancel: (id: string, input: CancelOrderInput) =>
    apiClient<{ orderId: string; status: string; cancelledAt: string }>(
      `orders/${id}/cancel`,
      { method: "POST", body: input },
    ),

  simulatePayment: (amount: number, paymentCard: PaymentCard) =>
    apiClient<{ transactionId: string; status: string; processedAt: string }>(
      "payments/simulate",
      { method: "POST", body: { amount, paymentCard } },
    ),
};
