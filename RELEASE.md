# Release & Deployment Guide - Arrow Escape

## Android Release Configuration

- **Package Name**: `com.example.arrowescape`
- **Application Label**: `Arrow Escape`
- **Target SDK**: Android 34 (Android 14)
- **Min SDK**: Android 21 (Android 5.0)
- **Orientation**: Portrait Only (`android:screenOrientation="portrait"`)

---

## Pre-Release Checklist

1. **Static Analysis**:
   ```bash
   flutter analyze
   ```
   Ensure zero errors and zero warnings.

2. **Automated Tests**:
   ```bash
   flutter test
   ```
   Ensure all unit and widget tests pass.

---

## Build Release APK & App Bundle

### 1. Build Universal Release APK
```bash
flutter build apk --release
```
Output location:
`build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Android App Bundle (AAB) for Google Play Store
```bash
flutter build appbundle --release
```
Output location:
`build/app/outputs/bundle/release/app-release.aab`

---

## Key Configuration Locations Before Store Publishing

- **Package Identifier**: Change `com.example.arrowescape` in:
  - `android/app/build.gradle` (`namespace` and `applicationId`)
  - `android/app/src/main/AndroidManifest.xml` (`package`)
  - `android/app/src/main/kotlin/com/example/arrowescape/MainActivity.kt` (`package`)
- **Version Number**: Update `version: 1.0.0+1` in `pubspec.yaml`.
