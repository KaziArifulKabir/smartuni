# 🎓 SmartUni - Smart University Management App

**SmartUni** is a modern, cross-platform mobile application built with **Flutter** and **Firebase**. It is designed to streamline university life by providing students with quick access to their courses, academic notices, and personal profiles in one place.

## ✨ Key Features

* 🔐 **User Authentication:** Secure student registration and login powered by Firebase Authentication.
* 📊 **Student Dashboard:** A clean, intuitive home screen for quick navigation across university services.
* 📚 **Courses & Subjects:** View enrolled subjects, course details, and academic schedules.
* 📢 **Notice Board:** Stay updated with real-time university announcements and important notices via Cloud Firestore.
* 👤 **Student Profile:** Manage and view personal student information seamlessly.
* 🎨 **Modern UI/UX:** Custom theme support (`app_theme.dart`) for a consistent and responsive user experience.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev) (Dart)
* **Backend & Database:** [Firebase](https://google.com) (Firebase Auth, Cloud Firestore)
* **Architecture:** Clean modular structure (`models`, `screens`, `services`, `theme`)

## 📂 Project Structure
smartuni/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── notice_model.dart
│   │   ├── subject_model.dart
│   │   └── user_model.dart
│   ├── screens/
│   │   ├── courses_screen.dart
│   │   ├── login_screen.dart
│   │   ├── notice_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── register_screen.dart
│   │   └── student_dashboard.dart
│   ├── services/
│   │   ├── firebase_auth_service.dart
│   │   └── firestore_service.dart
│   └── theme/
│       └── app_theme.dart
├── assets/
├── pubspec.yaml
└── firebase.json

## 🚀 Getting Started

Follow these steps to run the project locally on your machine:

### 1. Clone the repository
git clone https://github.com
cd smartuni

### 2. Generate platform files (`android` & `ios`)
Since platform-specific folders are excluded from this repository, generate them automatically by running:
flutter create .

### 3. Install dependencies
flutter pub get

### 4. Configure Firebase
Since sensitive Firebase configuration files (`firebase_options.dart`, `google-services.json`) are excluded for security, connect your own Firebase project using FlutterFire CLI:
flutterfire configure

### 5. Run the app
flutter run

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com).

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).
