import { z } from "zod";
import { normalizePhoneNumber } from "@/lib/utils/phone";

const passwordRules = z
  .string()
  .min(12, "Şifre en az 12 karakter olmalı")
  .max(128, "Şifre en fazla 128 karakter olabilir")
  .regex(/[A-Z]/, "En az bir büyük harf gerekli")
  .regex(/[a-z]/, "En az bir küçük harf gerekli")
  .regex(/[0-9]/, "En az bir rakam gerekli");

export const loginSchema = z.object({
  email: z.string().email("Geçerli bir e-posta girin"),
  password: z.string().min(1, "Şifre gerekli"),
});

const registerFields = {
  email: z.string().email("Geçerli bir e-posta girin"),
  password: passwordRules,
  passwordConfirm: z.string().min(1, "Şifre tekrarı gerekli"),
  firstName: z.string().min(1, "Ad gerekli"),
  lastName: z.string().min(1, "Soyad gerekli"),
  phoneNumber: z
    .string()
    .min(10, "Geçerli telefon numarası girin")
    .transform(normalizePhoneNumber)
    .refine((value) => /^\+[1-9][0-9]{7,14}$/.test(value), {
      message: "Telefon +905551234567 formatında olmalı",
    }),
};

const passwordMatchRefine = {
  message: "Şifreler eşleşmiyor",
  path: ["passwordConfirm"],
};

export const registerSchema = z
  .object(registerFields)
  .refine((data) => data.password === data.passwordConfirm, passwordMatchRefine);

export const verifyEmailSchema = z.object({
  sessionId: z.string().min(1),
  code: z.string().min(4, "Doğrulama kodu gerekli"),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email("Geçerli bir e-posta girin"),
});

export const resetPasswordSchema = z
  .object({
    sessionId: z.string().min(1),
    code: z.string().min(4, "Doğrulama kodu gerekli"),
    newPassword: z.string().min(8, "Şifre en az 8 karakter olmalı"),
    newPasswordConfirm: z.string().min(1, "Şifre tekrarı gerekli"),
  })
  .refine((data) => data.newPassword === data.newPasswordConfirm, {
    message: "Şifreler eşleşmiyor",
    path: ["newPasswordConfirm"],
  });

export const updateProfileSchema = z.object({
  firstName: z.string().min(1, "Ad gerekli"),
  lastName: z.string().min(1, "Soyad gerekli"),
  phoneNumber: z.string().min(10, "Geçerli telefon numarası girin"),
  photoId: z.string().nullable().optional(),
});

export const changePasswordSchema = z
  .object({
    currentPassword: z.string().min(1, "Mevcut şifre gerekli"),
    newPassword: z.string().min(8, "Yeni şifre en az 8 karakter olmalı"),
    newPasswordConfirm: z.string().min(1, "Şifre tekrarı gerekli"),
  })
  .refine((data) => data.newPassword === data.newPasswordConfirm, {
    message: "Şifreler eşleşmiyor",
    path: ["newPasswordConfirm"],
  });

export const registerSellerSchema = z
  .object({
    ...registerFields,
    storeName: z.string().min(1, "Mağaza adı gerekli").max(160),
    taxNumber: z
      .string()
      .regex(/^[0-9]{10,11}$/, "Vergi numarası 10-11 haneli olmalı"),
    taxOffice: z.string().min(1, "Vergi dairesi gerekli").max(120),
  })
  .refine((data) => data.password === data.passwordConfirm, passwordMatchRefine);

export const changeEmailSchema = z.object({
  newEmail: z.string().email("Geçerli bir e-posta girin"),
  password: z.string().min(1, "Şifre gerekli"),
});

export const verifyEmailChangeSchema = z.object({
  sessionId: z.string().min(1),
  code: z.string().min(4, "Doğrulama kodu gerekli"),
});

export type ChangeEmailInput = z.infer<typeof changeEmailSchema>;
export type VerifyEmailChangeInput = z.infer<typeof verifyEmailChangeSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type RegisterSellerInput = z.infer<typeof registerSellerSchema>;
export type VerifyEmailInput = z.infer<typeof verifyEmailSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
