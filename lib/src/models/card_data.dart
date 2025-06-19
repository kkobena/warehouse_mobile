import 'package:json_annotation/json_annotation.dart';
import 'package:warehouse_mobile/src/models/list_item.dart';

part 'card_data.g.dart';
@JsonSerializable()
class CardData {
  final String title;
  final List<ListItem> items;
  final List<ListItem> summary;

  CardData({required this.title,required this.items,required this.summary} );

  // Factory constructor for deserialization
  factory CardData.fromJson(Map<String, dynamic> json) => _$CardDataFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$CardDataToJson(this);

}
