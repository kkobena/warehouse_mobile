// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie_inventaire.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategorieInventaireAdapter extends TypeAdapter<CategorieInventaire> {
  @override
  final int typeId = 4;

  @override
  CategorieInventaire read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategorieInventaire(
      name: fields[0] as String,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CategorieInventaire obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorieInventaireAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorieInventaire _$CategorieInventaireFromJson(Map<String, dynamic> json) =>
    CategorieInventaire(
      name: json['name'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$CategorieInventaireToJson(
        CategorieInventaire instance) =>
    <String, dynamic>{
      'name': instance.name,
      'label': instance.label,
    };
