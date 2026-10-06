# 📚 DeadlineAlert — Hướng dẫn cài đặt & chạy

## Yêu cầu môi trường
- Flutter SDK ≥ 3.0.0
- Android Studio hoặc VS Code
- Tài khoản [Supabase](https://supabase.com) (miễn phí)

---

## 1. Cấu hình Supabase

### Bước 1: Tạo project Supabase
1. Vào [https://supabase.com](https://supabase.com) → New Project
2. Đặt tên project (ví dụ: `deadline-alert`), chọn region **Southeast Asia (Singapore)**
3. Lưu lại **Project URL** và **anon public key**

### Bước 2: Chạy SQL migration
1. Vào **SQL Editor** trong Supabase dashboard
2. Copy toàn bộ nội dung file [`supabase/migrations/001_initial_schema.sql`](supabase/migrations/001_initial_schema.sql)
3. Paste và nhấn **Run**

### Bước 3: Cấu hình trong app
Mở file [`lib/core/constants/app_constants.dart`](lib/core/constants/app_constants.dart):

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';       // ← Thay thế
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // ← Thay thế
```

Ví dụ:
```dart
static const String supabaseUrl = 'https://abcxyz.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 2. Cài đặt & Chạy

```bash
# Cài packages
flutter pub get

# Generate code (freezed + riverpod)
dart run build_runner build --delete-conflicting-outputs

# Chạy trên thiết bị/emulator
flutter run
```

---

## 3. Build APK (Android)

```bash
flutter build apk --release
```

File APK sẽ ở: `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Cài đặt Widget Android

Sau khi cài app:
1. Nhấn giữ màn hình chính
2. Chọn **Widget**
3. Tìm **Deadline Alert**
4. Kéo widget vào màn hình

---

## 5. Tính năng chính

| Tính năng | Mô tả |
|---|---|
| 🔐 Đăng ký/Đăng nhập | Tài khoản riêng, bảo mật dữ liệu cá nhân |
| 📚 Quản lý môn học | Thêm/sửa/xóa, màu sắc tùy chỉnh |
| ⏰ Deadline | Thêm deadline, đặt mức ưu tiên, nhắc nhở |
| 📷 OCR | Chụp ảnh thông báo, tự nhận dạng văn bản |
| 📊 Import | Import từ file Excel/CSV |
| 🔔 Thông báo | Push notification nhắc trước deadline |
| 📱 Widget | Hiển thị deadline sắp đến trên màn hình chính |

---

## 6. Cấu trúc dữ liệu Import (Excel/CSV)

Khi import môn học từ Excel/CSV, file cần có các cột:
```
Tên môn | Mã môn | Giảng viên | Deadline | Mô tả
```

Ví dụ CSV:
```csv
name,code,lecturer,deadline_title,deadline_date
Lập trình Python,CS101,Nguyễn Văn A,Bài tập 1,2026-11-15 23:59
Cơ sở dữ liệu,CS201,Trần Thị B,Báo cáo đồ án,2026-11-20 23:59
```

---

## 7. Liên hệ & Đóng góp

Đây là dự án open source. Mọi đóng góp đều được chào đón!
