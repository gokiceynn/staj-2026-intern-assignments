import { z } from "zod";

export const productFilterSchema = z.object({
  page: z.coerce.number().int().min(1).optional(),
  size: z.coerce.number().int().min(1).max(100).optional(),
  q: z.string().optional(),
  categoryId: z.string().optional(),
  minPrice: z.coerce.number().min(0).optional(),
  maxPrice: z.coerce.number().min(0).optional(),
  sortBy: z
    .enum(["price_asc", "price_desc", "rating_desc", "newest"])
    .optional(),
});

export type ProductFilterInput = z.infer<typeof productFilterSchema>;
