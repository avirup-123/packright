import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'category.dart';

part 'trip.g.dart';

/// Trip Model
/// Represents a complete trip with all its packing categories and items
@HiveType(typeId: 2)
class Trip extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<Category> categories;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Trip({
    String? id,
    required this.name,
    required this.description,
    this.categories = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this trip with optional field overrides
  Trip copyWith({
    String? id,
    String? name,
    String? description,
    List<Category>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the total number of items across all categories
  int get totalItems {
    return categories.fold(0, (sum, category) => sum + category.items.length);
  }

  /// Get the total number of packed items across all categories
  int get packedItems {
    return categories.fold(0, (sum, category) => sum + category.packedCount);
  }

  /// Get the overall completion percentage
  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return packedItems / totalItems;
  }

  /// Get a short preview of the description (first ~50 characters)
  String get descriptionPreview {
    if (description.length <= 50) return description;
    return '${description.substring(0, 50)}...';
  }

  /// Format the creation date for display
  String get formattedCreatedAt {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Created ${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deserialize from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((cat) => Category.fromJson(cat as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}