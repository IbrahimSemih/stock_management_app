# App Icon

Place your app icon files here:

## Required Files

1. **app_icon.png** (1024x1024 pixels)
   - Main app icon
   - Used for iOS, Android, Web, Windows, macOS
   - Should have transparent background for best results

2. **app_icon_foreground.png** (1024x1024 pixels)
   - Foreground layer for Android adaptive icons
   - Should have transparent background
   - Icon should be centered with padding

## Generating Icons

After placing your icon files, run:

```bash
dart run flutter_launcher_icons
```

## Design Tips

- Use simple, recognizable shapes
- Ensure icon is visible at small sizes
- Test on both light and dark backgrounds
- Follow platform-specific guidelines:
  - [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
  - [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)

## Current Settings

- Adaptive Icon Background: #1A237E (Dark Blue)
- Minimum Android SDK: 21

