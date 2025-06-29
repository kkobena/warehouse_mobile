import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'categorie_inventaire.g.dart';
@HiveType(typeId: 4)
@JsonSerializable()
class CategorieInventaire extends HiveObject {
  @HiveField(0)
final String name;
  @HiveField(1)
final String label;

CategorieInventaire({
  required this.name,
  required this.label,
});

  factory CategorieInventaire.fromJson(Map<String, dynamic> json) =>
      _$CategorieInventaireFromJson(json);

  Map<String, dynamic> toJson() => _$CategorieInventaireToJson(this);
}