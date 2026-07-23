import { z } from "zod";

export const addressSchema = z.object({
  title: z.string().min(1, "Başlık gerekli"),
  addressLine: z.string().min(5, "Adres en az 5 karakter olmalı"),
  city: z.string().min(1, "Şehir gerekli"),
  district: z.string().min(1, "İlçe gerekli"),
  zipCode: z.string().min(5, "Posta kodu gerekli"),
  phoneNumber: z.string().min(10, "Geçerli telefon numarası girin"),
});

export type AddressInput = z.infer<typeof addressSchema>;
