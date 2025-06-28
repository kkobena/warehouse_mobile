import 'package:hive/hive.dart';

part 'rayon.g.dart';

@HiveType(typeId: 0)
class Rayon extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String code;
  @HiveField(2)
  final String libelle;
  @HiveField(3)
  final int? storageId;
  @HiveField(4)
  final String? storageLibelle;
  @HiveField(5)
  final int inventoryId;


  Rayon({
    required this.id,
    required this.code,
    required this.libelle,
    this.storageId,
    this.storageLibelle,
    required this.inventoryId,

  });
}
