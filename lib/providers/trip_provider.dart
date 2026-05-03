import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/storage_service.dart';

/// Trip Provider
/// Manages trip state and provides CRUD operations
class TripProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Trip> _trips = [];
  bool _isLoading = false;

  /// Get the list of trips
  List<Trip> get trips => _trips;

  /// Check if the provider is currently loading
  bool get isLoading => _isLoading;

  /// Check if there are no trips
  bool get isEmpty => _trips.isEmpty;

  /// Get the storage service instance
  StorageService get storageService => _storageService;

  /// Initialize the provider and load trips from storage
  Future<void> init() async {
    await _storageService.init();
    await loadTrips();
  }

  /// Load all trips from storage
  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = _storageService.getAllTrips();
    } catch (e) {
      debugPrint('Error loading trips: $e');
      _trips = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new trip
  Future<void> addTrip(Trip trip) async {
    try {
      await _storageService.saveTrip(trip);
      _trips.insert(0, trip); // Add to the beginning of the list
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding trip: $e');
      rethrow;
    }
  }

  /// Delete a trip by ID
  Future<void> deleteTrip(String tripId) async {
    try {
      await _storageService.deleteTrip(tripId);
      _trips.removeWhere((trip) => trip.id == tripId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      rethrow;
    }
  }

  /// Update an existing trip
  Future<void> updateTrip(Trip trip) async {
    try {
      await _storageService.updateTrip(trip);
      final index = _trips.indexWhere((t) => t.id == trip.id);
      if (index != -1) {
        _trips[index] = trip;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating trip: $e');
      rethrow;
    }
  }

  /// Delete all trips
  Future<void> deleteAllTrips() async {
    try {
      await _storageService.deleteAllTrips();
      _trips.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting all trips: $e');
      rethrow;
    }
  }

  /// Get a trip by ID
  Trip? getTripById(String tripId) {
    try {
      return _trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  /// Rename a trip
  Future<void> renameTrip(String tripId, String newName) async {
    final trip = getTripById(tripId);
    if (trip != null) {
      await updateTrip(trip.copyWith(name: newName));
    }
  }

  /// Generate a trip name from description
  static String generateTripName(String description) {
    // Take the first few words of the description
    final words = description.trim().split(RegExp(r'\s+'));
    if (words.length <= 3) {
      return description.trim();
    }
    return '${words.sublist(0, 3).join(' ')}...';
  }
}