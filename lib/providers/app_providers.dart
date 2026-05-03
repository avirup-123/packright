import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/index.dart';

// Storage provider
final storageProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Trips provider
final tripsProvider = FutureProvider<List<Trip>>((ref) async {
  final storage = ref.watch(storageProvider);
  return storage.getAllTrips();
});

// Current trip provider
final currentTripProvider = StateProvider<Trip?>((ref) => null);

// Packing items provider for current trip
final packingItemsProvider = FutureProvider<List<PackingItem>>((ref) async {
  final storage = ref.watch(storageProvider);
  final currentTrip = ref.watch(currentTripProvider);

  if (currentTrip == null) {
    return [];
  }

  return storage.getItemsForTrip(currentTrip.id);
});

// Loading state for generating packing list
final generatingPackingListProvider = StateProvider<bool>((ref) => false);

// Error state
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Trip input controller
final tripInputProvider = StateProvider<String>((ref) => '');
