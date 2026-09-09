# FazLauncher

An advanced Android game launcher specifically designed for the Five Nights at Freddy's (FNAF) series. This application provides a centralized interface for managing, downloading, and launching various FNAF titles while offering personalization features and a dedicated character gallery.

## Features

- Game Management: Automated downloading, installation, and launching of FNAF 1, 2, 3, and 4.
- Animatronic Gallery: A high-quality gallery system categorized by game version to view character renders.
- Background Personalization: Support for both static images and animated GIF backgrounds across different FNAF themes.
- Console-Style UI: A sleek, landscape-oriented interface with a dedicated navigation sidebar optimized for mobile devices.
- Progress Tracking: Real-time download progress and storage information for all managed games.

## Technology Stack

- Framework: Flutter (Landscape Orientation)
- Networking: HTTP for handling game asset downloads.
- Storage: shared_preferences for persisting user settings and background choices.
- Native Integration: installed_apps and open_filex for managing APK interactions on Android.
- CI/CD: GitHub Actions for automated multi-architecture APK builds (Universal, ARM64, ARMV7).

## Installation and Setup

### Prerequisites
- Flutter SDK (Compatible with version 3.13.2 and higher)
- Android SDK (Targeting API 35)
- Java Development Kit (JDK 17)

### Build Instructions
1. Clone the repository to your local machine.
2. Navigate to the project root and execute 'flutter pub get' to fetch dependencies.
3. Place required game images and backgrounds into the 'assets/' directory.
4. Use 'flutter run' to deploy the application to a connected Android device or emulator.

## CI/CD Workflow

The project is configured with a GitHub Actions workflow that handles:
- Static code analysis and formatting checks.
- Automated APK generation for multiple architectures.
- Automatic GitHub Release creation when pushing version tags (e.g., v1.0.0).

## Credits

Developed by the Fazlauncher Group:
- radin6262
- omid

Copyright 2026 ARR.
