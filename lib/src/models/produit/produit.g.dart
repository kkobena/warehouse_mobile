// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Produit _$ProduitFromJson(Map<String, dynamic> json) => Produit(
  id: (json['id'] as num).toInt(),
  libelle: json['libelle'] as String,
  codeCip: json['codeCip'] as String?,
  rayonLibelle: json['rayonLibelle'] as String?,
  totalQuantity: (json['totalQuantity'] as num?)?.toInt(),
  qtyReserve: (json['qtyReserve'] as num?)?.toInt(),
  tvaTaux: (json['tvaTaux'] as num?)?.toInt(),
  regularUnitPrice: (json['regularUnitPrice'] as num?)?.toInt(),
  grossAmount: (json['grossAmount'] as num?)?.toInt(),
  fournisseurProduits: (json['fournisseurProduits'] as List<dynamic>?)
      ?.map((e) => ProduitFournisseur.fromJson(e as Map<String, dynamic>))
      .toList(),
  stockProduits: (json['stockProduits'] as List<dynamic>?)
      ?.map((e) => ProduitStock.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastDateOfSale: json['lastDateOfSale'] == null
      ? null
      : DateTime.parse(json['lastDateOfSale'] as String),
  lastOrderDate: json['lastOrderDate'] == null
      ? null
      : DateTime.parse(json['lastOrderDate'] as String),
  lastInventoryDate: json['lastInventoryDate'] == null
      ? null
      : DateTime.parse(json['lastInventoryDate'] as String),
);

Map<String, dynamic> _$ProduitToJson(Produit instance) => <String, dynamic>{
  'id': instance.id,
  'libelle': instance.libelle,
  'codeCip': instance.codeCip,
  'rayonLibelle': instance.rayonLibelle,
  'totalQuantity': instance.totalQuantity,
  'qtyReserve': instance.qtyReserve,
  'tvaTaux': instance.tvaTaux,
  'regularUnitPrice': instance.regularUnitPrice,
  'grossAmount': instance.grossAmount,
  'fournisseurProduits': instance.fournisseurProduits,
  'stockProduits': instance.stockProduits,
  'lastDateOfSale': instance.lastDateOfSale?.toIso8601String(),
  'lastOrderDate': instance.lastOrderDate?.toIso8601String(),
  'lastInventoryDate': instance.lastInventoryDate?.toIso8601String(),
};
