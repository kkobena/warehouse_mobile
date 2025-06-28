import 'package:hive/hive.dart';
import 'package:warehouse_mobile/src/models/inventaire/inventaire_item.dart';

part 'rayon_inventaire_item.g.dart';

@HiveType(typeId: 2)
class RayonInventaireItem extends HiveObject {
  @HiveField(0)
  final int rayonId;
  @HiveField(1)
  final List<InventaireItem> items;

  RayonInventaireItem({
    required this.rayonId,
    required this.items,
  });
}
