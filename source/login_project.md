# Stajyerler için 1 Haftalık Proje Planı: Login Sistemi

Bu proje, öğrencilerin modern bir web ve mobil uygulamanın temel taşı olan kimlik doğrulama (authentication) sistemini geliştirmelerine odaklanır. Proje, Backend, Frontend (Web) ve Mobil olmak üzere üç takıma ayrılmıştır. Her takım, bir hafta içinde kendi alanındaki görevleri tamamlayarak bütünleşik bir login/register akışı oluşturacaktır.

---

## 1. Backend Projesi: Authentication API (.NET)

**Referans API Yapısı:**
- `POST /auth/register`: Yeni kullanıcı kaydı.
- `POST /auth/login`: Kullanıcı girişi ve token üretimi.
- `POST /auth/logout`: (İsteğe bağlı) Oturumu sonlandırma.

**Amaç:** Frontend ve Mobil uygulamaların güvenli bir şekilde kullanıcı kaydı yapmasını ve oturum açmasını sağlayan bir servis oluşturmak. Başarılı giriş sonrası JWT (JSON Web Token) gibi bir token ile yanıt vermek.

**Teknolojiler:**
- **Çerçeve:** .NET Core Web API
- **Veritabanı:** Entity Framework Core ile SQLite veya SQL Server Express.
- **Kimlik Doğrulama:** JWT (JSON Web Tokens)

**Beklenen Çıktı:** Postman ile test edilebilir, en az iki ana endpoint'i (`/register`, `/login`) çalışan ve JWT üreten bir API servisi.

---

## 2. Frontend Projesi: Web Login Arayüzü

**Referans Tasarım:** [Figma - Logify Web Login UI Kit](https://www.figma.com/community/file/1019155319918719973/logify-web-login-ui-kit)

**Amaç:** Kullanıcıların kayıt olabileceği ve giriş yapabileceği, modern ve responsive bir web arayüzü geliştirmek. Başarılı giriş sonrası kullanıcıyı korumalı bir sayfaya yönlendirmek.

**Teknolojiler:**
- **Seçenek 1 (React):** Vite, Context API (Auth durumu için), React Router DOM, Tailwind CSS.
- **Seçenek 2 (Angular):** Angular CLI, RxJS, Angular Material.

**Beklenen Çıktı:** Figma tasarımına sadık, API ile entegre çalışan, tarayıcıda kullanıcı oturumunu (token) yöneten ve dağıtıma hazır bir web uygulaması.

---

## 3. Mobil Projesi: Mobil Login Arayüzü

**Referans Tasarım:** [Figma - Mobile Login UI Kit](https://www.figma.com/community/file/1160170957712796540/mobile-login-ui-kit)

**Amaç:** iOS ve Android'de çalışabilen, kullanıcıların kayıt olup giriş yapabildiği bir mobil uygulama geliştirmek.

**Teknolojiler:**
- Flutter SDK, Dart, Provider/BLoC, http, shared_preferences.

**Beklenen Çıktı:** Emülatörde veya gerçek bir cihazda çalıştırılabilen, API entegrasyonu tamamlanmış, Login ve Register ekranları olan bir mobil uygulama.