import { apiClient } from "@/lib/api/client";
import { normalizePaginated } from "@/lib/api/pagination";
import { withPhotoUrls } from "@/lib/utils/photo-url";
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

function mapOrderDetail(order: OrderDetail): OrderDetail {
  return { ...order, items: withPhotoUrls(order.items) };
}

export const ordersApi = {
  list: async (params?: { page?: number; size?: number }): Promise<Paginated<OrderSummary>> =>
    normalizePaginated<OrderSummary>(
      await apiClient<unknown>("orders", { params }),
    ),

  getById: async (id: string) =>
    mapOrderDetail(await apiClient<OrderDetail>(`orders/${id}`)),

  checkout: (input: CheckoutInput) => {
    const idempotencyKey = crypto.randomUUID().replace(/-/g, "");
    return apiClient<OrderDetail>("orders/checkout", {
      method: "POST",
      body: input,
      headers: { "Idempotency-Key": idempotencyKey },
    });
  },

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
