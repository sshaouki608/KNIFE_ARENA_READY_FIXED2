# KNIFE ARENA

Offline-first 2D Flutter + Flame mobile game prototype.

## Project contents
- `lib/`: Flutter app UI and Flame game logic.
- `android/`: Android app platform using Flutter embedding v2 and API 35 target.
- `pubspec.yaml`: Flutter dependencies.
- `BUILD_NOTES_AR.md`: Arabic setup and release notes.

## Build
Requires a compatible Flutter SDK, Android SDK, and Java 17. From the project root:

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

The APK output is normally `build/app/outputs/flutter-apk/app-release.apk`.

**Release signing:** the Gradle file uses debug signing for local testing. Configure the organization's release keystore before publishing.
