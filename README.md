# flutter_ui_fundamentals

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Course Explorer v2 - Flutter Architecture Audit

Proyek ini menerapkan Clean Architecture dengan Separation of Concerns dan Provider State Management.

## Identitas Praktikan
- **Nama:** Putu Krisna Wiryatama
- **NIM:** 2415051099
- **Program Studi:** Pendidikan Teknik Informatika

---

## Tanggung Jawab Struktur Folder (Tahap 16)

| Folder | Tanggung Jawab |
| :--- | :--- |
| `constants/` | Menyimpan konstanta global seperti identitas mahasiswa dan konfigurasi aplikasi yang tidak berubah. |
| `models/` | Merepresentasikan struktur data (*entity*) dengan keamanan tipe (*type safety*) dan sentralisasi parsing JSON (`Course.fromJson`). |
| `services/` | Mengelola akses teknis ke sumber data mentah (*data source*), seperti membaca `rootBundle` aset JSON lokal atau panggilan REST API. |
| `repositories/` | Berperan sebagai lapisan abstraksi antara *data source* dan *state management*, menyediakan API data yang konsisten dan terisolasi. |
| `providers/` | Mengelola *application state* (`courses`, `isLoading`, `error`, `favorites`) menggunakan `ChangeNotifier` tanpa bergantung pada `BuildContext`. |
| `widgets/` | Menyediakan komponen UI modular dan dapat digunakan kembali (*reusable*), seperti `CourseCard` dan modal lembar favorit. |
| `screens/` | Menampilkan antarmuka pengguna utama, menangani tata letak adaptif (*responsive layout*), serta menerima aksi pengguna tanpa memproses data mentah secara langsung. |

---

## Alur Ketergantungan (Dependency Direction)
```text
UI (Screens & Widgets) ➔ Provider (CourseProvider) ➔ Repository (CourseRepository) ➔ Service (CourseService)

## REST API Documentation (Pertemuan 7)
- **Base URL**: `https://course-api-pearl.vercel.app`
- **Endpoint Latihan**: `GET /courses`
- **Struktur Response**:
  - `id` (int): Primary key resource
  - `code` (string): Kode unik mata kuliah (misal: "MOB01")
  - `title` (string): Nama mata kuliah
  - `credits` (int): Bobot SKS
  - `status` (string): "planned" | "active" | "done"

Buat table database course di Supabase

# Course Data Manager (Course Explorer v2)

Aplikasi manajemen mata kuliah responsif berbasis Flutter dengan implementasi **Repository Pattern**, **Provider State Management**, dan integrasi ganda backend (**REST API MockAPI** & **PostgreSQL Supabase**).

## Identitas Pengembang
- **Nama:** Putu Krisna Wiryatama
- **NIM:** 2415051099
- **Program Studi:** Pendidikan Teknik Informatika
- **Institusi:** Universitas Pendidikan Ganesha

---

## Arsitektur Aplikasi
Aplikasi menerapkan prinsip *Separation of Concerns* (SoC) dengan struktur layer berikut:
- **Presentation Layer (`screens/`, `widgets/`):** Menangani antarmuka pengguna yang responsif (`NavigationBar` / `NavigationRail`), visualisasi data, form modal CRUD, dan feedback dialog/SnackBar.
- **State Management (`providers/`):** Mengelola state aplikasi (`CourseProvider`) untuk status loading, data courses, error state, dan sinkronisasi list favorites.
- **Repository Layer (`repositories/`):** Sebagai *single source of truth* (`CourseRepository`) yang menjembatani layer presentasi dengan data source.
- **Data Source Layer (`services/`):** Mengimplementasikan kontrak abstrak `CourseDataSource` untuk memudahkan pergantian backend:
  - `CourseApiService`: Berkomunikasi dengan MockAPI REST endpoint.
  - `CourseSupabaseService`: Berkomunikasi langsung dengan PostgreSQL Supabase.

---

## Backend & Database
- **Database Engine:** PostgreSQL via Supabase
- **Tabel Utama:** `public.courses`
  - Kolom: `id` (bigint/identity), `code` (text), `title` (text), `credits` (int), `status` (text), `created_at` (timestamp)
  - Constraint: `CHECK (status IN ('planned', 'active', 'done'))`
  - Keamanan: Row Level Security (RLS) diaktifkan dengan policy akses untuk kebutuhan laboratorium.

---

## Cara Menjalankan Proyek

1. **Clone Repository:**
   ```bash
   git clone [https://github.com/KrisnaWiryatama/flutter_ui_fundamentals.git](https://github.com/KrisnaWiryatama/flutter_ui_fundamentals.git)
   cd flutter_ui_fundamentals