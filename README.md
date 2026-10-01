# doist

A Flutter application with Shorebird code push integration for over-the-air updates.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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

### CI/CD Pipeline

The `.github/workflows/cd.yml` handles:
- **Patch job**: Runs on pushes to `main`, publishes Shorebird patch
- **Release job**: Runs on version tags (`v*`), builds release, creates GitHub Release with AAB/APK artifacts

### Secrets Required

Configure these in GitHub repository settings (Settings → Secrets and variables → Actions):
- `SHOREBIRD_TOKEN` - Shorebird API token from [Shorebird Console](https://console.shorebird.dev)