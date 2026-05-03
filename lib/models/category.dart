import 'package:hive/hive.dart';
import 'packing_item.dart';

part 'category.g.dart';

/// Category Model
/// Represents a packing category (e.g., Clothing, Electronics)
@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String iconName;

  @HiveField(2)
  List<PackingItem> items;

  Category({
    required this.name,
    required this.iconName,
    this.items = const [],
  });

  /// Create a copy of this category with optional field overrides
  Category copyWith({
    String? name,
    String? iconName,
    List<PackingItem>? items,
  }) {
    return Category(
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      items: items ?? this.items,
    );
  }

  /// Get the number of packed items
  int get packedCount => items.where((item) => item.isPacked).length;

  /// Get the total number of items
  int get totalCount => items.length;

  /// Get the completion percentage
  double get completionPercentage {
    if (totalCount == 0) return 0.0;
    return packedCount / totalCount;
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconName': iconName,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Deserialize from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PackingItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}