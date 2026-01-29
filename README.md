# 📦 SmartStock - Inventory Management System

<p align="center">
  <img src="screenshots/banner.png" alt="SmartStock Banner" width="100%">
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#usage">Usage</a> •
  <a href="#support">Support</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.2+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.9.2+-blue.svg" alt="Dart Version">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg" alt="Platform">
  <img src="https://img.shields.io/badge/License-Regular-orange.svg" alt="License">
</p>

---

## 🌟 Overview

**SmartStock** is a powerful, modern, and feature-rich inventory management application built with Flutter. Perfect for small to medium businesses, retail stores, warehouses, and anyone who needs to track their stock efficiently.

### Why SmartStock?

- ✅ **Beautiful UI/UX** - Modern Material 3 design with dark/light themes
- ✅ **Offline First** - Works without internet, syncs when connected
- ✅ **Barcode Scanner** - Quick product lookup with camera
- ✅ **Multi-language** - English and Turkish support
- ✅ **Export Reports** - PDF and Excel export functionality
- ✅ **Cloud Backup** - Firebase Firestore integration for data safety
- ✅ **User Data Isolation** - Each account's data is completely separate and secure
- ✅ **Cross-Platform** - Android and iOS support

---

## ✨ Features

### 📱 Product Management
- Add, edit, and delete products
- Product images support
- Barcode/QR code scanning
- Category and brand organization
- Stock level tracking
- Purchase and sale price management

### 📊 Dashboard & Analytics
- Real-time stock overview
- Critical stock alerts
- Recent products list
- Quick action buttons
- Visual statistics

### 📁 Categories & Brands
- Unlimited categories
- Brand management
- Easy organization

### 📈 Reports & Export
- Export to PDF (with Turkish character support)
- Export to Excel
- Database backup & restore
- Share reports via apps

### 🔐 Authentication & Data Security
- Firebase Authentication
- Email/password login
- Offline mode support
- User profile management
- **User-specific data isolation** - Each account's data is completely separate

### 🎨 Customization
- Light/Dark theme
- System theme auto-detection
- Currency settings
- Low stock threshold settings
- Notification preferences

### 🌍 Localization
- English language
- Turkish language (Türkçe)
- Easy to add more languages

---

## 📸 Screenshots

<p align="center">
  <img src="screenshots/1_login.png" width="200" alt="Login">
  <img src="screenshots/2_dashboard.png" width="200" alt="Dashboard">
  <img src="screenshots/3_products.png" width="200" alt="Products">
  <img src="screenshots/4_categories.png" width="200" alt="Categories">
</p>

<p align="center">
  <img src="screenshots/5_add_product.png" width="200" alt="Add Product">
  <img src="screenshots/6_barcode.png" width="200" alt="Barcode Scanner">
  <img src="screenshots/7_reports.png" width="200" alt="Reports">
  <img src="screenshots/8_settings.png" width="200" alt="Settings">
</p>

---

## 🛠 Installation

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code
- Firebase account (for authentication & cloud sync) - Free tier available

### Step 1: Extract the Package

```bash
unzip smartstock.zip
cd smartstock
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (free tier available)
3. Enable **Authentication**:
   - Go to **Authentication > Sign-in method**
   - Enable **Email/Password** provider
4. Enable **Firestore Database**:
   - Go to **Firestore Database**
   - Create database in **Production mode** or **Test mode**
   - Set up security rules (see below)
5. Add your app to Firebase:
   - **Android**: Add Android app with package name `com.devisb.stock_management`
   - Download `google-services.json` and place it in `android/app/`
   - **iOS**: Add iOS app with bundle ID
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Option B: Manual Configuration

1. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console
2. Place them in the correct directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### Firestore Security Rules

Set up these security rules in Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Note:** The app works in offline mode without Firebase configuration. Cloud sync is optional.

### Step 4: Run the App

```bash
# For Android
flutter run

# For iOS
cd ios && pod install && cd ..
flutter run
```

### Step 5: Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## ⚙️ Configuration

### Changing App Name

1. **Android**: Edit `android/app/src/main/AndroidManifest.xml`
```xml
android:label="Your App Name"
```

2. **iOS**: Edit `ios/Runner/Info.plist`
```xml
<key>CFBundleName</key>
<string>Your App Name</string>
```

### Changing Package Name

Use the `change_app_package_name` package:
```bash
flutter pub add change_app_package_name --dev
flutter pub run change_app_package_name:main com.yourcompany.yourapp
```

### Changing App Icon

1. Place your icon in `assets/icon/` directory
2. Update `pubspec.yaml`:
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```
3. Run:
```bash
flutter pub run flutter_launcher_icons:main
```

### Adding New Languages

1. Create new locale file in `lib/l10n/`
2. Add translations
3. Update `lib/l10n/app_localizations.dart`

---

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # App configuration
├── routes.dart            # Navigation routes
├── firebase_options.dart  # Firebase configuration
├── config/                # Configuration files
│   └── firebase_config.dart
├── l10n/                  # Localization files
│   ├── app_localizations.dart
│   ├── app_en.dart        # English translations
│   └── app_tr.dart        # Turkish translations
├── models/                # Data models
│   ├── product.dart
│   ├── category.dart
│   ├── brand.dart
│   ├── stock_history.dart
│   └── price_history.dart
├── providers/             # State management
│   ├── product_provider.dart
│   ├── category_provider.dart
│   ├── brand_provider.dart
│   ├── auth_provider.dart
│   ├── settings_provider.dart
│   ├── sync_provider.dart
│   └── ...
├── screens/               # UI screens
│   ├── dashboard_screen.dart
│   ├── login_screen.dart
│   ├── settings_screen.dart
│   ├── products/
│   └── ...
├── services/              # Business logic
│   ├── db_helper.dart
│   ├── export_service.dart
│   └── sync_service.dart  # Firebase sync
├── utils/                 # Utilities
│   ├── constants.dart
│   └── app_icons.dart
└── widgets/               # Reusable widgets
    ├── premium_widgets.dart
    ├── product_card.dart
    └── ...
```

---

## 🔧 Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter 3.9.2+ | Cross-platform framework |
| Provider | State management |
| SQLite (sqflite) | Local database |
| Firebase Auth | Authentication |
| Firebase Firestore | Cloud backup & sync (optional) |
| mobile_scanner | Barcode scanning |
| pdf & printing | PDF generation |
| excel | Excel export |
| shared_preferences | Local settings |

---

## 📝 Changelog

### Version 1.0.0 (Initial Release)
- ✅ Product management (CRUD)
- ✅ Category & brand management
- ✅ Stock tracking with history
- ✅ Barcode/QR scanner
- ✅ Firebase authentication
- ✅ Firebase Firestore cloud sync
- ✅ **User-specific data isolation** - Each account's data is completely separate
- ✅ PDF & Excel export
- ✅ Database backup & restore
- ✅ Dark/Light theme
- ✅ English & Turkish language
- ✅ Modern Material 3 UI

---

## 🆘 Support

### Documentation
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Customization Guide](docs/CUSTOMIZATION.md)
- [FAQ](docs/FAQ.md)

### Getting Help
If you have questions or need support:
1. Check the documentation first
2. Review closed issues for similar problems
3. Contact support via CodeCanyon

### Reporting Bugs
When reporting bugs, please include:
- Device model and OS version
- Flutter version (`flutter --version`)
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

---

## 📄 License

This project is licensed under the CodeCanyon Regular License. You can:
- ✅ Use for a single end product
- ✅ Use for personal or client project
- ❌ Resell or redistribute the source code
- ❌ Use in multiple projects (requires extended license)

See [LICENSE](LICENSE) for full details.

---

## 🙏 Credits

- [Flutter](https://flutter.dev) - Google's UI toolkit
- [Firebase](https://firebase.google.com) - Backend services & authentication
- [Material Design 3](https://m3.material.io) - Design system
- Icons by [Font Awesome](https://fontawesome.com)

---

<p align="center">
  Made with ❤️ using Flutter
</p>

<p align="center">
  <strong>Thank you for purchasing SmartStock!</strong>
</p>
