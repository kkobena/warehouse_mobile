// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tva_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TvaItem _$TvaItemFromJson(Map<String, dynamic> json) => TvaItem(
  type: json['type'] as String,
  ttc: json['ttc'] as String,
  tva: json['tva'] as String,
  ht: json['ht'] as String,
  pourcentage: json['pourcentage'] as String,
);

Map<String, dynamic> _$TvaItemToJson(TvaItem instance) => <String, dynamic>{
  'type': instance.type,
  'ttc': instance.ttc,
  'tva': instance.tva,
  'ht': instance.ht,
  'pourcentage': instance.pourcentage,
};
