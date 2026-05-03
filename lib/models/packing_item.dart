import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'packing_item.g.dart';

/// PackingItem Model
/// Represents a single item in a packing category
@HiveType(typeId: 0)
class PackingItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  bool isPacked;

  PackingItem({
    String? id,
    required this.name,
    this.quantity = 1,
    this.isPacked = false,
  }) : id = id ?? const Uuid().v4();

  /// Create a copy of this item with optional field overrides
  PackingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isPacked,
  }) {
    return PackingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isPacked': isPacked,
    };
  }

  /// Deserialize from JSON
  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1,
      isPacked: json['isPacked'] as bool? ?? false,
    );
  }
}