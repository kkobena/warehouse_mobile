import 'package:json_annotation/json_annotation.dart';

part 'tva_item.g.dart';

@JsonSerializable()
class TvaItem {
  final String type;
  final String ttc;
  final String tva;
  final String ht;
  final String pourcentage;

  TvaItem({
    required this.type,
    required this.ttc,
    required this.tva,
    required this.ht,
    required this.pourcentage,
  });

  // Factory constructor for deserialization
  factory TvaItem.fromJson(Map<String, dynamic> json) =>
      _$TvaItemFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$TvaItemToJson(this);
}
