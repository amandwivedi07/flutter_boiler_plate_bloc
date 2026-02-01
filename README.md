# Clean Architecture Flutter Boilerplate

> Production-ready Flutter boilerplate with Clean Architecture, BLoC/Cubit, Firebase, Dio, go_router, and get_it.

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## Features

| Category | Stack |
|----------|-------|
| **Architecture** | Clean Architecture (Domain, Data, Presentation) |
| **State Management** | flutter_bloc (Cubit) |
| **Networking** | Dio (with auth interceptor) |
| **Auth** | Firebase Auth |
| **Push Notifications** | Firebase Cloud Messaging |
| **Routing** | go_router (auth guards, deep linking) |
| **DI** | get_it |
| **Local Storage** | SharedPreferences (caching) |
| **Environments** | dev / staging / prod |

---

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) 3.9+
- [Firebase](https://console.firebase.google.com) project
- Android Studio / Xcode (for mobile)

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/clean_boilerplate.git
cd clean_boilerplate
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase setup

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Add an **Android** and/or **iOS** app to your project
3. Download config files:
   - **Android**: `google-services.json` → place in `android/app/`
   - **iOS**: `GoogleService-Info.plist` → place in `ios/Runner/`

**Option A – FlutterFire CLI (recommended)**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` and configures platforms automatically.

**Option B – Manual**

- Copy `google-services.json` to `android/app/`
- Copy `GoogleService-Info.plist` to `ios/Runner/`

4. In Firebase Console:
   - Enable **Authentication** → Email/Password
   - Enable **Cloud Messaging** (optional, for push notifications)

### 4. (Optional) Set API base URL

Edit `lib/core/config/env_config.dart` or pass at build time:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.com
```

### 5. Run the app

```bash
flutter run
```

---

## Environment configuration

| Environment | Dart define | API URL |
|-------------|-------------|---------|
| **Dev** (default) | `ENV=dev` | `https://dev-api.example.com` |
| **Staging** | `ENV=staging` | `https://staging-api.example.com` |
| **Production** | `ENV=prod` | `https://api.example.com` |

**Run / build commands:**

```bash
# Development (default)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production build
flutter build apk --dart-define=ENV=prod
```

---

## Project structure

```
lib/
├── main.dart
├── di/injection.dart              # Dependency injection (get_it)
├── core/                          # Shared utilities
│   ├── config/                    # Environment (dev/staging/prod)
│   ├── network/                   # DioClient, ApiInterceptor
│   ├── router/                    # go_router, auth guards
│   ├── errors/                    # Result<T>, Failure
│   ├── storage/                   # LocalStorage
│   ├── theme/                     # Light/dark themes
│   └── ...
├── firebase/                      # FirebaseService, NotificationService
└── features/
    └── auth/                      # Auth feature
        ├── data/                  # Models, DataSources, Repository Impl
        ├── domain/                # Entities, Repository (abstract), UseCases
        └── presentation/          # Cubit, State, Pages
```

---

## Initial instructions after setup

### 1. Rename the project (optional)

Edit `pubspec.yaml`:

```yaml
name: your_app_name
description: "Your app description"
```

Then run:

```bash
dart run change_app_package_name:main your_app_name
# Or rename manually in android/ and ios/
```

### 2. Update Firebase project

- Replace `google-services.json` / `GoogleService-Info.plist` with your project’s config
- Enable desired auth methods in Firebase Console
- Add API keys or other secrets via environment variables or dart-define

### 3. Configure API base URL

Edit `lib/core/config/env_config.dart`:

```dart
static String get apiBaseUrl => switch (current) {
  Environment.dev => 'https://your-dev-api.com',
  Environment.staging => 'https://your-staging-api.com',
  Environment.prod => 'https://your-api.com',
};
```

### 4. Run tests

```bash
flutter test
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [How to create a new module](README.md#how-to-create-a-new-module) | Step-by-step guide for adding features |
| [BLoC & Clean Architecture guide](docs/README_BLOC.md) | Beginner-friendly BLoC/Cubit and architecture guide |

---

## Troubleshooting

### Firebase initialization failed

- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in the correct paths
- Run `flutter clean && flutter pub get` and try again

### API calls failing

- Check `lib/core/config/env_config.dart` for correct `apiBaseUrl`
- Verify Dio interceptor auth token (Firebase `getIdToken`) if required

### Build errors

```bash
flutter clean
flutter pub get
flutter run
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
# flutter_boiler_plate_bloc
