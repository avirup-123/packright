import 'package:hive/hive.dart';
import '../models/trip.dart';
import '../models/category.dart';
import '../models/packing_item.dart';

/// Storage Service
/// Wraps Hive operations for persistent data storage
class StorageService {
  static const String _tripsBoxName = 'trips';
  static const String _settingsBoxName = 'settings';

  late Box<Trip> _tripsBox;
  late Box _settingsBox;

  /// Initialize the storage service
  Future<void> init() async {
    // Register Hive adapters
    Hive.registerAdapter(PackingItemAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TripAdapter());

    // Open boxes
    _tripsBox = await Hive.openBox<Trip>(_tripsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // ========== Trip Operations ==========

  /// Save a new trip or update an existing one
  Future<void> saveTrip(Trip trip) async {
    await _tripsBox.put(trip.id, trip);
  }

  /// Get all trips sorted by creation date (most recent first)
  List<Trip> getAllTrips() {
    final trips = _tripsBox.values.toList();
    trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trips;
  }

  /// Get a single trip by ID
  Trip? getTrip(String tripId) {
    return _tripsBox.get(tripId);
  }

  /// Delete a trip by ID
  Future<void> deleteTrip(String tripId) async {
    await _tripsBox.delete(tripId);
  }

  /// Update an existing trip
  Future<void> updateTrip(Trip trip) async {
    await _tripsBox.put(trip.id, trip.copyWith(updatedAt: DateTime.now()));
  }

  /// Delete all trips
  Future<void> deleteAllTrips() async {
    await _tripsBox.clear();
  }

  /// Get the number of trips
  int get tripCount => _tripsBox.length;

  // ========== Settings Operations ==========

  /// Save a setting value
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting value
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Check if this is the first launch
  bool get isFirstLaunch {
    final launched = _settingsBox.get('hasLaunched', defaultValue: false);
    return !launched;
  }

  /// Mark app as launched
  Future<void> markAsLaunched() async {
    await _settingsBox.put('hasLaunched', true);
  }

  /// Get the theme mode setting (true = dark, false = light)
  bool get isDarkMode => _settingsBox.get('isDarkMode', defaultValue: false);

  /// Set the theme mode
  Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('isDarkMode', value);
  }

  // ========== Utility Methods ==========

  /// Close all boxes
  Future<void> close() async {
    await _tripsBox.close();
    await _settingsBox.close();
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAll() async {
    await _tripsBox.clear();
    await _settingsBox.clear();
  }
}