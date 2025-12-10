# ❓ Frequently Asked Questions (FAQ)

## General Questions

### What platforms does SmartStock support?
SmartStock supports both **Android** and **iOS** platforms. It's built with Flutter for cross-platform compatibility.

### Do I need a server?
No server is required for basic functionality. The app uses SQLite for local storage. Firebase is only needed for authentication and optional cloud backup.

### Can I use the app offline?
Yes! The app works completely offline. All data is stored locally on the device. Firebase authentication requires internet only for login/logout.

### How many products can I add?
There's no limit. SQLite can handle millions of records efficiently.

---

## Installation Issues

### "Flutter not found" error
Make sure Flutter is installed and added to PATH:
```bash
flutter doctor
```

### Build fails on Android
Try cleaning and rebuilding:
```bash
flutter clean
flutter pub get
flutter build apk
```

### Build fails on iOS
1. Install CocoaPods: `sudo gem install cocoapods`
2. Run: `cd ios && pod install && cd ..`
3. Open in Xcode and update signing team

### "google-services.json not found"
1. Download from Firebase Console
2. Place in `android/app/` directory
3. Not in `android/app/src/` - directly in `android/app/`

---

## Firebase Issues

### Authentication not working
1. Check if Email/Password is enabled in Firebase Console
2. Verify `google-services.json` is correct
3. Check internet connection
4. Try: `flutter clean && flutter pub get`

### "No Firebase App" error
Firebase is not initialized. Ensure:
1. `google-services.json` is in correct location
2. `build.gradle` has Google Services plugin
3. `main.dart` initializes Firebase

### Firestore permission denied
Update security rules in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## App Features

### Barcode scanner not working
1. Grant camera permission when asked
2. Check if camera is not used by other apps
3. Ensure good lighting for scanning
4. Try restarting the app

### PDF export shows wrong characters
The app uses Noto Sans font for PDF which supports Turkish and other special characters. If you still see issues:
1. Check if `printing` package is installed
2. Ensure font files are included in assets

### Database backup not restoring
1. Select only `.db` files for restore
2. Make sure the backup file is complete (not corrupted)
3. Try exporting a new backup first

### Critical stock alerts not showing
1. Go to Settings → Notifications
2. Enable "Low Stock Alerts"
3. Set appropriate threshold value

---

## Customization

### How to change app colors?
Edit `lib/utils/constants.dart` and modify `AppColors` class. See [Customization Guide](CUSTOMIZATION.md).

### How to add new language?
1. Create translation file in `lib/l10n/`
2. Update `app_localizations.dart`
3. See [Customization Guide](CUSTOMIZATION.md) for details.

### How to change app name?
Edit:
- Android: `android/app/src/main/AndroidManifest.xml` → `android:label`
- iOS: `ios/Runner/Info.plist` → `CFBundleDisplayName`

### How to change app icon?
1. Prepare 1024x1024 PNG icon
2. Use `flutter_launcher_icons` package
3. See [Customization Guide](CUSTOMIZATION.md)

---

## Data & Privacy

### Where is data stored?
All data is stored locally on the device in SQLite database. Location:
- Android: `/data/data/com.example.app/databases/`
- iOS: Application Documents directory

### How to backup data?
Go to Reports → Export Database. This creates a `.db` file you can save anywhere.

### How to restore data?
Go to Reports → Restore Database. Select the `.db` backup file.

### Is my data secure?
- Local data is protected by device security
- Firebase uses secure authentication
- No data is sent to third parties

---

## Performance

### App is slow with many products
1. The app is optimized for large datasets
2. If slow, try: Settings → Clear Cache
3. Restart the app

### Large database file
Use database optimization:
1. Delete unused products/categories
2. Export and re-import database

### Battery usage
The app uses minimal battery. Barcode scanner uses more when active.

---

## Licensing

### Can I use for multiple clients?
Regular License: One end product only
Extended License: Multiple projects allowed

### Can I resell the code?
No. The code is licensed for use, not redistribution.

### Can I modify the code?
Yes! You can modify and customize for your needs.

---

## Getting Support

### Where to get help?
1. Check this FAQ first
2. Read documentation in `/docs` folder
3. Contact support via CodeCanyon

### What to include in support request?
1. Clear description of the issue
2. Steps to reproduce
3. Screenshots if possible
4. Device/OS information
5. Flutter version (`flutter --version`)

---

## Updates

### How to update the app?
1. Backup your current project
2. Download new version from CodeCanyon
3. Replace files (keep your customizations)
4. Run `flutter pub get`

### Will updates break my customizations?
We try to maintain backward compatibility. Always backup before updating.

---

<p align="center">
  Still have questions? Contact support via CodeCanyon.
</p>

