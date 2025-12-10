# 🎨 Customization Guide

This guide explains how to customize SmartStock for your needs.

---

## 📱 App Name & Identifier

### Change App Name

**Android:**
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
    ...>
```

**iOS:**
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Your App Name</string>
```

### Change Package Name

1. Install package:
```bash
flutter pub add change_app_package_name --dev
```

2. Run command:
```bash
dart run change_app_package_name:main com.yourcompany.yourapp
```

3. Update Firebase with new package name

---

## 🎨 App Icon

### Using flutter_launcher_icons

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A237E"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

2. Add your icon (1024x1024 PNG recommended)

3. Generate icons:
```bash
dart run flutter_launcher_icons
```

---

## 🌈 Colors & Theme

### Primary Colors

Edit `lib/utils/constants.dart`:

```dart
class AppColors {
  // Primary Colors - Change these
  static const Color primary = Color(0xFF1A237E);      // Main color
  static const Color primaryLight = Color(0xFF534bae);
  static const Color primaryDark = Color(0xFF000051);
  
  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF62efff);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
```

### Gradients

```dart
static const LinearGradient primaryGradient = LinearGradient(
  colors: [
    Color(0xFF1A237E),  // Start color
    Color(0xFF3949AB),  // End color
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

---

## 🔤 Fonts

### Add Custom Font

1. Add font files to `assets/fonts/`

2. Update `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: YourFont
      fonts:
        - asset: assets/fonts/YourFont-Regular.ttf
        - asset: assets/fonts/YourFont-Bold.ttf
          weight: 700
        - asset: assets/fonts/YourFont-Light.ttf
          weight: 300
```

3. Update theme in `lib/utils/constants.dart`:
```dart
static ThemeData get lightTheme => ThemeData(
  fontFamily: 'YourFont',
  // ...
);
```

---

## 🌍 Languages

### Add New Language

1. Create translation file `lib/l10n/app_xx.dart`:
```dart
const Map<String, String> appXx = {
  'app_name': 'Your Translation',
  'login': 'Login Translation',
  // Add all keys...
};
```

2. Update `lib/l10n/app_localizations.dart`:
```dart
static const supportedLocales = [
  Locale('en'),
  Locale('tr'),
  Locale('xx'),  // Add new locale
];

static Map<String, String> _getTranslations(String languageCode) {
  switch (languageCode) {
    case 'tr':
      return appTr;
    case 'xx':
      return appXx;  // Add new case
    default:
      return appEn;
  }
}
```

3. Add locale to `lib/app.dart`:
```dart
supportedLocales: const [
  Locale('en'),
  Locale('tr'),
  Locale('xx'),  // Add here too
],
```

---

## 💰 Currency

### Change Default Currency

Edit `lib/utils/constants.dart`:
```dart
static const String defaultCurrency = '₺';  // Change to $, €, £, etc.
static const String currencyCode = 'TRY';   // Change to USD, EUR, GBP, etc.
```

### Add Currency Selection

The app supports dynamic currency selection. Users can change it in Settings.

---

## 📊 Dashboard Layout

### Modify Quick Actions

Edit `lib/screens/dashboard_screen.dart`:

```dart
Widget _buildQuickActionsSection() {
  return GridView.count(
    crossAxisCount: 2,  // Change grid columns
    children: [
      // Add or remove action cards
      PremiumActionCard(
        icon: Icons.add_box,
        title: 'Custom Action',
        onTap: () => Navigator.pushNamed(context, '/custom'),
      ),
    ],
  );
}
```

### Modify Stats Cards

```dart
Widget _buildStatsSection() {
  // Customize which stats to show
  return Row(
    children: [
      PremiumStatCard(
        title: 'Custom Stat',
        value: '100',
        icon: Icons.star,
      ),
    ],
  );
}
```

---

## 🔔 Notifications

### Configure Low Stock Threshold

Edit `lib/utils/constants.dart`:
```dart
static const int defaultLowStockThreshold = 10;  // Change default
```

Users can also customize this in Settings screen.

---

## 📄 PDF Export

### Customize PDF Template

Edit `lib/services/export_service.dart`:

```dart
static Future<pw.Document> _generatePDF() {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        children: [
          // Add your company logo
          pw.Image(yourLogo),
          
          // Customize header
          pw.Text('Your Company Name'),
          
          // Modify table columns
          pw.Table(
            children: [
              // Customize columns
            ],
          ),
        ],
      ),
    ),
  );
  
  return pdf;
}
```

---

## 🚀 Splash Screen

### Customize Splash

Edit `lib/screens/splash_screen.dart`:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        children: [
          // Replace with your logo
          Image.asset('assets/your_logo.png'),
          
          // Customize text
          Text('Your App Name'),
        ],
      ),
    ),
  );
}
```

### Native Splash Screen

1. Add package:
```bash
flutter pub add flutter_native_splash
```

2. Configure `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#1A237E"
  image: assets/splash.png
  android: true
  ios: true
```

3. Generate:
```bash
dart run flutter_native_splash:create
```

---

## 📁 Database

### Change Database Name

Edit `lib/services/db_helper.dart`:
```dart
static const _dbName = 'your_app_name.db';
```

### Add New Table

```dart
FutureOr<void> _onCreate(Database db, int version) async {
  // Existing tables...
  
  // Add your new table
  await db.execute('''
    CREATE TABLE your_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at TEXT
    );
  ''');
}
```

---

## Need Help?

Contact support via CodeCanyon for customization assistance.

