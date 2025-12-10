# 🔥 Firebase Setup Guide

This guide will help you configure Firebase for SmartStock.

## Prerequisites

- Google account
- Firebase Console access
- Flutter SDK installed

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name (e.g., "SmartStock")
4. Disable Google Analytics (optional)
5. Click **"Create project"**
6. Wait for project creation

---

## Step 2: Add Android App

1. In Firebase Console, click **Android icon** (Add app)
2. Enter Android package name:
   - Find in `android/app/build.gradle.kts`
   - Look for `applicationId` (e.g., `com.example.stock_management`)
3. Enter app nickname: "SmartStock Android"
4. Enter SHA-1 certificate (for Google Sign-In):

```bash
# Windows
cd android
.\gradlew signingReport

# Mac/Linux
cd android
./gradlew signingReport
```

5. Click **"Register app"**
6. Download `google-services.json`
7. Move file to `android/app/` directory

---

## Step 3: Add iOS App (Optional)

1. In Firebase Console, click **iOS icon** (Add app)
2. Enter iOS bundle ID:
   - Find in `ios/Runner.xcodeproj/project.pbxproj`
   - Or open Xcode and check "Bundle Identifier"
3. Enter app nickname: "SmartStock iOS"
4. Click **"Register app"**
5. Download `GoogleService-Info.plist`
6. Move file to `ios/Runner/` directory

---

## Step 4: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **Email/Password**:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

---

## Step 5: Configure Firestore (Optional)

If you want cloud backup:

1. Go to **Firestore Database**
2. Click **"Create database"**
3. Select mode:
   - **Production mode** (recommended for live apps)
   - **Test mode** (for development)
4. Select location closest to your users
5. Click **"Enable"**

### Firestore Security Rules

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

---

## Step 6: Verify Configuration

### Android Configuration Check

Ensure `android/app/build.gradle.kts` has:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // This line
}
```

Ensure `android/build.gradle.kts` has:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")  // This line
    }
}
```

### iOS Configuration Check

Ensure `ios/Runner/Info.plist` has Firebase URL schemes (auto-added usually).

---

## Step 7: Test Connection

Run the app and try to:

1. Register a new account
2. Login with the account
3. Logout and login again

If everything works, Firebase is configured correctly! 🎉

---

## Troubleshooting

### "No Firebase App" Error

Make sure `google-services.json` is in `android/app/` directory.

### "SHA-1 mismatch" Error

Regenerate SHA-1 and add it to Firebase Console:
1. Go to Project Settings → Your Apps → Android
2. Add SHA-1 fingerprint

### iOS Build Errors

Run:
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Authentication Not Working

1. Check if Email/Password is enabled in Firebase Console
2. Verify internet connection
3. Check Firebase rules

---

## Security Best Practices

1. **Never commit** `google-services.json` to public repositories
2. Add to `.gitignore`:
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```
3. Use environment variables for sensitive data
4. Set proper Firestore security rules
5. Enable App Check for production

---

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Overview](https://firebase.flutter.dev/docs/overview)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth)

---

<p align="center">
  Need help? Contact support via CodeCanyon.
</p>

