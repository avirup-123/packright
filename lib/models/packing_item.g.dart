part of 'packing_item.dart';

/// Generated Hive adapter for PackingItem
class PackingItemAdapter extends TypeAdapter<PackingItem> {
  @override
  final int typeId = 0;

  @override
  PackingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldIndex = reader.readByte();
      fields[fieldIndex] = reader.read();
    }

    return PackingItem(
      id: fields[0] as String,
      name: fields[1] as String,
      quantity: (fields[2] as num).toInt(),
      isPacked: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PackingItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.isPacked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}