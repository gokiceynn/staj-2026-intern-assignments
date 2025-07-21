# Stajyerler için 1 Haftalık Proje Planı: Pet Store

Bu proje, öğrencilerin Backend, Frontend, Mobil ve Yapay Zeka geliştirme alanlarındaki yetkinliklerini kullanarak tam teşekküllü bir "Pet Store" uygulaması geliştirmelerini hedefler. Proje, dört ana takıma ayrılmıştır. Her takım, bir hafta içinde kendi alanındaki görevleri tamamlayarak projenin bütünleşik bir şekilde çalışmasına katkıda bulunacaktır.

**Ana Referans API:** [Swagger Petstore](https://petstore.swagger.io/)

---

## 1. Backend Projesi: Pet Store API Geliştirme

**Amaç:** Frontend, Mobil ve AI uygulamalarının ihtiyaç duyacağı veri ve servis altyapısını sağlamak. `pet`, `store` ve `user` kaynakları için CRUD operasyonlarını içeren endpoint'ler geliştirmek.

**Teknolojiler:**
- **Seçenek 1 (Node.js):** Express.js, TypeScript, Prisma veya Mongoose. Veritabanı olarak SQLite veya PostgreSQL.
- **Seçenek 2 (.NET):** .NET Core Web API, Entity Framework Core. Veritabanı olarak SQL Server Express veya SQLite.

**Beklenen Çıktı:** Postman ile test edilebilir, belgelenmiş (Swagger/OpenAPI) ve dağıtıma hazır bir API servisi.

---

## 2. Frontend Projesi: Pet Store Web Uygulaması

**Referans Tasarım:** [Figma - Pet Shop App Landing Page](https://www.figma.com/community/file/1333739760381547963/app-landing-page-pet-shop-community)

**Amaç:** Kullanıcıların evcil hayvanları listeleyebileceği, detaylarını görebileceği ve satın alabileceği interaktif ve responsive bir web sitesi geliştirmek.

**Teknolojiler:**
- **Seçenek 1 (React):** Vite, Next.js, Context API/Redux Toolkit, Tailwind CSS.
- **Seçenek 2 (Angular):** Angular CLI, RxJS, Angular Material.

**Beklenen Çıktı:** Figma tasarımına sadık, API ile entegre çalışan ve dağıtıma hazır bir web uygulaması.

---

## 3. Mobil Projesi: Pet Store Mobil Uygulaması

**Referans Tasarım:** [Figma - Pet Shop App Community](https://www.figma.com/community/file/1431013424494506863/pet-shop-app-community)

**Amaç:** iOS ve Android'de çalışabilen, kullanıcıların evcil hayvanları görüntüleyip arayabileceği, favorilerine ekleyebileceği bir mobil uygulama oluşturmak.

**Teknolojiler:**
- Flutter SDK, Dart, Provider/BLoC, http.

**Beklenen Çıktı:** Emülatörde çalıştırılabilen, API entegrasyonu tamamlanmış bir mobil uygulama.

---

## 4. Yapay Zeka Projesi: Akıllı Evcil Hayvan Asistanı

**Amaç:** İki temel AI özelliği sunan bir servis oluşturmak:
1.  **Otomatik İçerik Üretimi:** Sisteme yeni eklenen bir evcil hayvan için (tür, yaş, cins gibi temel bilgilere dayanarak) otomatik olarak ilgi çekici ve sıcak bir tanıtım metni oluşturmak.
2.  **Kişiselleştirilmiş Öneri:** Kullanıcının yaşam tarzı ve tercihlerine (örneğin "apartmanda yaşıyorum", "enerjik bir köpek arıyorum") göre en uygun evcil hayvanları önermek.

**Teknolojiler:**
- **Dil ve Çerçeve:** Python ve FastAPI veya Flask.
- **Yapay Zeka:** Google Gemini veya OpenAI GPT gibi bir üretken yapay zeka modelinin API'si.

**Beklenen Çıktı:** Frontend ve mobil ekiplerin çağırabileceği, en az iki adet endpoint'e (`/generate-description` ve `/recommend-pet`) sahip, test edilebilir bir AI servisi.