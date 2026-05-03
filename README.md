# PackRight - AI-Powered Travel Packing List App

PackRight is a Flutter mobile app that generates smart, personalized packing lists from natural language trip descriptions using Google's Gemini AI.

## Features

✨ **Smart List Generation**
- Describe your trip in natural language
- AI understands context (destination, activities, climate, accommodation)
- Generates comprehensive, contextually appropriate packing lists

🚀 **Fast & Frictionless**
- No sign-up required
- Works completely offline
- Data saved instantly to your device
- Three taps from app open to holding a perfect packing list

📱 **Cross-Platform**
- Built with Flutter for iOS and Android
- Native performance and smooth UI
- Works on all modern devices

💾 **Always There**
- All data stored locally on your phone
- Never lose your packing lists
- Complete privacy - your data never leaves your device

## Getting Started

### Prerequisites

- Flutter 3.13+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart SDK (comes with Flutter)
- Android Studio or Xcode (for emulator/device setup)
- Google Gemini API key ([Get API key](https://ai.google.dev/))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/packright.git
   cd packright
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up API Key**
   - Get your Gemini API key from [Google AI Studio](https://ai.google.dev/)
   - Create a `.env` file in the project root:
     ```
     GEMINI_API_KEY=your_api_key_here
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
packright/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── trip.dart             # Trip data model
│   │   ├── packing_item.dart     # Packing item model
│   │   └── index.dart
│   ├── screens/
│   │   ├── home_screen.dart      # Home/trips list
│   │   ├── trip_input_screen.dart # Trip description input
│   │   └── packing_list_screen.dart # Packing list display
│   ├── services/
│   │   ├── gemini_service.dart   # AI integration
│   │   └── storage_service.dart  # Local data persistence
│   ├── providers/
│   │   └── app_providers.dart    # State management
│   ├── widgets/
│   │   └── common_widgets.dart   # Reusable UI components
│   └── constants/
│       └── theme.dart            # Theme and constants
├── assets/
│   ├── images/
│   └── icons/
├── test/
├── pubspec.yaml
└── README.md
```

## Key Dependencies

- **google_generative_ai** - Gemini AI integration
- **flutter_riverpod** - State management
- **hive_flutter** - Local data persistence
- **http** - HTTP requests
- **uuid** - Unique ID generation

## Usage

### Creating a Packing List

1. Open the app
2. Tap "New Trip" or "Start Planning"
3. Describe your trip:
   - Destination
   - Duration
   - Activities
   - Accommodation type
   - Any special requirements
4. Tap "Generate Packing List"
5. AI generates a personalized list
6. Check items off as you pack
7. All changes save automatically

### Managing Trips

- View all your trips on the home screen
- Tap any trip to view/edit its packing list
- Delete trips using the menu

## Development

### Build for Android
```bash
flutter build apk
flutter build appbundle  # For Google Play
```

### Build for iOS
```bash
flutter build ios
```

### Run Tests
```bash
flutter test
```

### Code Generation (if needed)
```bash
flutter pub run build_runner build
```

## API Reference

### Models

**Trip**
- `id`: Unique identifier
- `description`: Natural language description of the trip
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

**PackingItem**
- `id`: Unique identifier
- `tripId`: Reference to the trip
- `name`: Item name
- `category`: Category (clothing, toiletries, electronics, etc.)
- `isChecked`: Whether the item is packed
- `quantity`: Item quantity
- `notes`: Additional notes
- `createdAt`: Creation timestamp

### Services

**GeminiService**
- `generatePackingList(trip: Trip)`: Generate items using AI

**StorageService**
- `saveTrip(trip)`: Save a trip
- `getTrip(id)`: Retrieve a trip
- `getAllTrips()`: Get all trips
- `deleteTrip(id)`: Delete a trip
- `saveItems(items)`: Save multiple packing items
- `getItemsForTrip(tripId)`: Get items for a trip
- `updateItem(item)`: Update an item
- `deleteItem(id)`: Delete an item

## Roadmap

- [ ] Photo attachments for items
- [ ] Share packing lists with others
- [ ] Packing list templates
- [ ] Weather integration
- [ ] Collaborative lists for groups
- [ ] Cloud sync option
- [ ] Custom categories
- [ ] Export to PDF/print
- [ ] Dark mode refinement
- [ ] Notifications/reminders

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

Found a bug or have a feature request? Please open an issue on GitHub.

## Authors

- Your Name - Initial work

---

**PackRight** - Smart packing for smart travelers 🎒✈️
