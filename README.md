# doist ![Logo](assets/images/logo.png)

A Flutter application with Shorebird code push integration for over-the-air updates.

## Tech Stack & Programming Languages
- **Framework**: Flutter (^3.9.2)
- **Language**: Dart
- **State Management**: Flutter Bloc + Hydrated Bloc
- **Localization**: flutter_intl (ARB files)
- **Dependencies**: 
  - equatable, uuid, path_provider, flutter_slidable, local_auth, smooth_page_indicator, lottie, flutter_animate, page_transition, flutter_launcher_icons
- **Dev Dependencies**: 
  - flutter_test, bloc_test, mocktail, flutter_lints
- **Assets**: 
  - Images (PNG/JPG), Lottie animations, Shorebird configuration
- **Tooling**: 
  - Shorebird CLI (for OTA updates), GitHub Actions (CI/CD)

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Shorebird Code Push](#shorebird-code-push)
- [CI/CD Pipeline](#cicd-pipeline)
- [Secrets Required](#secrets-required)
- [Contributing](#contributing)

## Project Overview
doist is a productivity app designed to help users manage tasks efficiently. It features a clean, minimalist interface with support for light/dark themes, multiple languages (English and Arabic), and persistent state management using Hydrated Bloc. The app includes onboarding, a home screen with task management, and a settings tab for customization.

## Features
- **Onboarding Flow**: Introductory screens to welcome users and explain core functionality.
- **Task Management**: Add, view, and manage tasks with a simple and intuitive interface.
- **Theme Support**: Light and dark themes with persistent storage via Hydrated Bloc.
- **Localization**: Full support for English and Arabic languages, with easy extension for more.
- **Bottom Navigation**: Seamless switching between Home and Settings tabs.
- **State Management**: Uses Flutter Bloc (with Hydrated Bloc for persistence) for predictable state handling.
- **Responsive Design**: Adaptive layout for various screen sizes.
- **Shorebird Integration**: Over-the-air (OTA) updates for Android via Shorebird.

## Architecture
The app follows a layered architecture with separation of concerns:
- **Presentation Layer**: Widgets, screens, and UI components.
- **Business Logic Layer**: Bloc-based state management (Bloc, Event, State) for each feature.
- **Data Layer**: Models and data handling (though currently minimal, as data is stored locally via Hydrated Bloc).
- **Dependency Injection**: BlocProvider is used to provide blocs to the widget tree.
- **Localization**: Uses `flutter_intl` and ARB files for internationalization.
- **Theming**: Centralized theme definitions in `app_theme.dart` and `font_manager.dart`.
- **Navigation**: Named routes with `PageTransition` for smooth transitions.

### State Management
- **SettingsBloc**: Manages app-wide settings (theme mode, language, onboarding completion).
- **HomeTabBloc**: Manages the state of tasks in the home tab (adding tasks, etc.).
- **OnBoardingBloc**: Manages the onboarding flow state.

### Persistence
Hydrated Bloc is used to persist bloc states (like theme, language, and onboarding status) across app restarts.

### Localization
- ARB files (`intl_en.arb`, `intl_ar.arb`) define localized strings.
- The `generated/l10n.dart` file is used to access localized strings via `S.of(context)`.

### Theming
- Light and dark themes are defined in `app_theme.dart`.
- Font sizes and weights are managed via `font_manager.dart`.

## Project Structure
```
lib/
├── generated/              # Generated localization files
├── home/                   # Home screen and widgets
├── home_tab/               # Home tab functionality (tasks)
│   ├── data/               # Data models (e.g., TaskModel)
│   ├── view/               # Screens and widgets for home tab
│   └── view_model/         # Bloc files (events, states, view_model)
├── l10n/                   # Localization ARB files
├── onBoarding/             # Onboarding flow
│   ├── data/               # Onboarding models
│   ├── view/               # Onboarding screens and widgets
│   └── view_model/         # Bloc files for onboarding
├── settings_tab/           # Settings tab functionality
│   ├── data/               # Settings models
│   ├── view/               # Settings screens and widgets
│   └── view_model/         # Bloc files for settings
├── shared/                 # Shared resources (themes, fonts, etc.)
├── splash/                 # Splash screen and localization
└── main.dart               # App entry point
```

### Key Files
- `main.dart`: Initializes Hydrated Bloc, sets up the app, and defines routing.
- `app_theme.dart`: Defines light and dark themes.
- `font_manager.dart`: Centralizes font sizes and weights.
- `splash/l10n.dart`: Initializes localization and delegates.
- Each feature tab (`home_tab`, `settings_tab`, `onBoarding`) follows a similar structure:
  - `data/models.dart`: Data classes.
  - `view/screens.dart`: UI screens.
  - `view/widgets.dart`: Reusable widgets.
  - `view_model/*_events.dart`: Bloc events.
  - `view_model/*_states.dart`: Bloc states.
  - `view_model/*_view_model.dart`: Bloc implementation.

## Getting Started
### Prerequisites
- Flutter SDK (^3.9.2)
- Shorebird CLI (for local releases)
- Android SDK (for Android builds)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/OmarAdel10/doist.git
   ```
2. Navigate to the project directory:
   ```bash
   cd doist
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
```bash
flutter run
```
This will launch the app on a connected device or emulator.

### Building for Release (Locally)
```bash
# Build Android App Bundle (AAB) and APK via Shorebird
shorebird release android --flutter-version latest
```

## Shorebird Code Push
This project uses [Shorebird](https://shorebird.dev) for over-the-air (OTA) updates on Android.

### How it works
- **Releases**: Built and published via GitHub Actions when a version tag (`v*`) is pushed
- **Patches**: Automatically published on every push to `main` branch for the latest release

### Creating a Release
1. Update the version in `pubspec.yaml` (e.g., `version: 1.0.0+1`)
2. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The CD pipeline will:
   - Build the Android App Bundle (AAB) and APK via Shorebird
   - Create a GitHub Release with the artifacts attached
   - Publish the release to Shorebird for OTA updates

### Publishing a Patch
Push to `main` branch to automatically publish a patch for the latest release:
```bash
git push origin main
```

### Local Development
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build release locally (requires Shorebird CLI)
shorebird release android --flutter-version latest
```

### Requirements
- Flutter SDK (^3.9.2)
- Shorebird CLI (for local releases)
- Android SDK (for Android builds)

## CI/CD Pipeline
The `.github/workflows/cd.yml` handles:
- **Patch job**: Runs on pushes to `main`, publishes Shorebird patch
- **Release job**: Runs on version tags (`v*`), builds release, creates GitHub Release with AAB/APK artifacts

## Secrets Required
Configure these in GitHub repository settings (Settings → Secrets and variables → Actions):
- `SHOREBIRD_TOKEN` - Shorebird API token from [Shorebird Console](https://console.shorebird.dev)

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please make sure to update tests as appropriate.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.