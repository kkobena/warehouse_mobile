import 'package:json_annotation/json_annotation.dart';
import 'package:warehouse_mobile/src/models/produit/produit_fournisseur.dart';
import 'package:warehouse_mobile/src/models/produit/produit_stock.dart';
part 'produit.g.dart';

@JsonSerializable()
class Produit {
  final int id;
  final String libelle;
  final String? codeCip;
  final String? rayonLibelle;
  final int? totalQuantity;
  final int? qtyReserve;
  final int? tvaTaux;
  final int? regularUnitPrice;
  final int? grossAmount;
//  final List<ProduitCommde>? commdes;
  final List<ProduitFournisseur>? fournisseurProduits;
  final List<ProduitStock>? stockProduits;
  //final List<ProduitVendu>? produitVendus;
  final DateTime? lastDateOfSale;
  final DateTime? lastOrderDate;
  final DateTime? lastInventoryDate;

Produit({
    required this.id,
    required this.libelle,
     this.codeCip,
     this.rayonLibelle,
    this.totalQuantity,
    this.qtyReserve,
     this.tvaTaux,
    this.regularUnitPrice,
    this.grossAmount,
    this.fournisseurProduits,
    this.stockProduits,
    this.lastDateOfSale,
    this.lastOrderDate,
    this.lastInventoryDate,
  });


  factory Produit.fromJson(Map<String, dynamic> json) => _$ProduitFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitToJson(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Produit && runtimeType == other.runtimeType && id == other.id && libelle == other.libelle;

  @override
  int get hashCode => id.hashCode ^ libelle.hashCode;



}