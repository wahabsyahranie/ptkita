# 💻 Source Code - Maintenance App

## 📥 Requirements

Pastikan sudah terinstall:

- Flutter SDK
- Android Studio / VSCode
- Dart

---

## 🚀 Cara Menjalankan Project

```bash
flutter pub get
flutter run
```

---

## 🏗️ Build APK

```bash
flutter build apk --release
```

---

## 📁 Struktur Project

```bash
lib/
 ├── models/
 ├── services/
 ├── repositories/
 ├── pages/
 ├── widgets/
```

---

## 🧠 Arsitektur

Menggunakan pola:

```
UI → Service → Repository → Firestore
```

### Aturan:

- UI hanya render
- Business logic di Service
- Repository handle Firestore
- Stream digunakan untuk data real-time

---

## 🔥 Data Flow

- Stream digunakan untuk:
  - Maintenance
  - Statistik

- Future digunakan untuk:
  - Inventory
  - Summary
  - Chart

---

## ⚠️ Catatan Developer

- Jangan melakukan query di UI
- Gunakan stream yang sudah di-cache di initState
- Hindari nested StreamBuilder

---

## 🔐 Firebase Setup

Tambahkan file berikut:

### Android:

```
android/app/google-services.json
```

### iOS:

```
ios/Runner/GoogleService-Info.plist
```

---

## 📌 Versi

v1.0.0

---
