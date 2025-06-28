// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rayon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RayonAdapter extends TypeAdapter<Rayon> {
  @override
  final int typeId = 0;

  @override
  Rayon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rayon(
      id: fields[0] as int,
      code: fields[1] as String,
      libelle: fields[2] as String,
      storageId: fields[3] as int?,
      storageLibelle: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Rayon obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.libelle)
      ..writeByte(3)
      ..write(obj.storageId)
      ..writeByte(4)
      ..write(obj.storageLibelle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RayonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
