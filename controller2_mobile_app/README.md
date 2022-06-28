Folder containing the mobile app in Flutter.

## Running
Scan the QR code below:

![image](https://user-images.githubusercontent.com/83274413/176196207-3110f5cd-ceb6-456c-bfae-60a6d726ff3a.png)

And install the app. Make sure to give it the permission to use camera (it is necessary to scan QR codes inside). Also, make sure you have a screen lock set up.
Platforms it has been tested on:
- Android 6 (Successfully installed and opened but stopped working) ❌
- Android 10 ✔️
- Android 9 ✔️

## Compiling
1. Make sure you have installed Android Studio and configured Flutter and Dart
2. Open the `controller2_mobile_app` directory in Android Studio
3. Run `flutter pub get`
4. Run the `main.dart` file in `controller2_mobile_app/lib/`

## Building apk
1. Open the `controller2_mobile_app` directory in Android Studio
2. Run in Android Studio terminal `flutter build apk --split-per-abi`
3. Find the suitable file for your device in `build/app/outputs/flutter-apk`. For most cases it will be `app-arm64-v8a-release`.
