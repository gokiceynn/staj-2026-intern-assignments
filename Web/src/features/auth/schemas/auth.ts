import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email("Geçerli bir e-posta girin"),
  password: z.string().min(1, "Şifre gerekli"),
});

export const registerSchema = z
  .object({
    email: z.string().email("Geçerli bir e-posta girin"),
    password: z.string().min(8, "Şifre en az 8 karakter olmalı"),
    passwordConfirm: z.string().min(1, "Şifre tekrarı gerekli"),
    firstName: z.string().min(1, "Ad gerekli"),
    lastName: z.string().min(1, "Soyad gerekli"),
    phoneNumber: z.string().min(10, "Geçerli telefon numarası girin"),
  })
  .refine((data) => data.password === data.passwordConfirm, {
    message: "Şifreler eşleşmiyor",
    path: ["passwordConfirm"],
  });

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

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type VerifyEmailInput = z.infer<typeof verifyEmailSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
