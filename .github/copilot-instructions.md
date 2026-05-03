# PackRight Flutter App - Copilot Instructions

## Project Overview
PackRight is an AI-powered travel packing list app that generates personalized packing checklists from natural language trip descriptions. Built with Flutter, uses Google's Gemini API for list generation, works offline, requires no sign-up.

## Key Features
✨ Smart List Generation
- Natural language trip input ("7 days in Bali, beach resort, snorkeling")
- AI-powered packing list generation using Google Gemini
- Context-aware recommendations based on destination, activities, climate

🚀 Fast & Frictionless
- Offline-first design with local data persistence
- No authentication required
- Data saves instantly to device
- Three taps from opening app to perfect packing list

📱 Cross-Platform
- Built with Flutter for iOS & Android
- Works on all modern devices
- Smooth native performance

💾 Privacy-First
- All data stored locally on device
- Complete privacy - data never leaves your phone
- Works without internet connection

## Tech Stack
- **Framework**: Flutter 3.13+
- **Language**: Dart 3.0+
- **AI API**: Google Gemini 1.5 Flash
- **State Management**: Flutter Riverpod
- **Local Storage**: Hive
- **HTTP Client**: http/dio

## Development Setup

### Prerequisites
- Flutter SDK 3.13+ ([Install](https://flutter.dev/docs/get-started/install))
- Dart SDK 3.0+
- Android Studio or Xcode
- Google Gemini API key ([Get API key](https://ai.google.dev/))

### Getting Started
1. Install dependencies: `flutter pub get`
2. Copy `.env.example` to `.env` and add your Gemini API key
3. Run: `flutter run`

## Project Structure
```
packright/
├── .github/
│   └── copilot-instructions.md    # This file
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/                    # Data models (Trip, PackingItem)
│   ├── screens/                   # UI screens
│   ├── services/                  # Business logic (Gemini, Storage)
│   ├── providers/                 # State management (Riverpod)
│   ├── widgets/                   # Reusable UI components
│   └── constants/                 # Theme and app constants
├── assets/
│   ├── images/
│   └── icons/
├── test/                          # Unit and widget tests
├── pubspec.yaml                   # Dependencies
├── README.md                       # User documentation
├── .env.example                   # Environment template
├── analysis_options.yaml          # Lint rules
└── .gitignore
```

## Build & Run
- Development: `flutter run`
- Android Release: `flutter build apk` or `flutter build appbundle`
- iOS Release: `flutter build ios`
- Tests: `flutter test`

## Key Dependencies
- **google_generative_ai** - Gemini API integration
- **flutter_riverpod** - State management
- **hive_flutter** - Local data persistence
- **uuid** - Unique ID generation
- **intl** - Internationalization
- **connectivity_plus** - Network detection

## Current Implementation Status
✅ Project structure scaffolded
✅ Models (Trip, PackingItem) created
✅ Services (GeminiService, StorageService) implemented
✅ State management providers set up
✅ UI screens (Home, TripInput, PackingList) created
✅ Reusable widgets built
✅ Theme system designed
✅ Tests structure initialized
⏳ Next: Connect Gemini API, build out JSON parsing, test on device

## Configuration
- Copy `.env.example` to `.env`
- Add your Google Gemini API key
- Never commit `.env` file
