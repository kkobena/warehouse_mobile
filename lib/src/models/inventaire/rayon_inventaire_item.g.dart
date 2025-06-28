// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rayon_inventaire_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RayonInventaireItemAdapter extends TypeAdapter<RayonInventaireItem> {
  @override
  final int typeId = 2;

  @override
  RayonInventaireItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RayonInventaireItem(
      rayonId: fields[0] as int,
      items: (fields[1] as List).cast<InventaireItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, RayonInventaireItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.rayonId)
      ..writeByte(1)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayonInventaireItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
