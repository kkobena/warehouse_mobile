import 'package:hive/hive.dart';
import 'package:warehouse_mobile/src/models/inventaire/inventaire.dart';
import 'package:warehouse_mobile/src/models/inventaire/inventaire_item.dart';
import 'package:warehouse_mobile/src/models/inventaire/rayon.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/service/shared_service.dart';
import 'package:warehouse_mobile/src/utils/service_state_wrapper.dart';

class InventaireService extends BaseServiceNotifier {
  final SharedService _sharedService;
  late Box<Inventaire> _inventaireBox;
  bool _isLoading = false;
  String _errorMessage = '';
  List<Inventaire>? _inventaires;

  List<Inventaire>? get inventaires => _inventaires;

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  bool get hasData => _inventaires != null && _inventaires!.isNotEmpty;

  InventaireService() : _sharedService = SharedService() {
    _initInventaireBox();
  }

  Future<void> _initInventaireBox() async {
    // Initialize the Hive box for Inventaire
    if (!Hive.isBoxOpen(Constant.hiveInventaireBox)) {
      await Hive.openBox<Inventaire>(Constant.hiveInventaireBox);
    } else {
      _inventaireBox = Hive.box<Inventaire>(Constant.hiveInventaireBox);
    }
  }

  Future<void> refresh() async {
    await _fetch(true);
  }

  Future<void> _fetch(bool refresh) async {
    _inventaires = await _sharedService.fetchListData<Inventaire>(
      endpoint: '/mobile/inventories',
      itemParserFromJson: (jsonData) => Inventaire.fromJson(jsonData),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _errorMessage = error,
      notifyListenersCallback: notifyListeners,
      saveListToHive: _saveAllToHive,
      loadListFromHive: _loadFromHive,
      forceRefresh:
          refresh, // Set to true if you want to bypass cache for this call
    );
  }

  Future<void> fetchAll() async {
    await _fetch(false);
  }

  Future<void> saveToHive(Inventaire inventaire) async {
    await _inventaireBox.put(inventaire.id, inventaire);
    notifyListeners();
  }

  Future<void> _saveAllToHive(List<Inventaire> inventaires) async {
    await _inventaireBox.clear(); // Clear existing data if needed
    for (var inventaire in inventaires) {
      await _inventaireBox.put(inventaire.id, inventaire);
    }
  }

  Future<List<Inventaire>?> _loadFromHive() async {
    final loadedData = _inventaireBox.values.toList();
    _inventaires = loadedData;
    return loadedData;
  }

  Future<void> cleanHive() async {
    await _inventaireBox.clear();
    await Hive.box<Rayon>(Constant.hiveRayonBox).clear();
    _inventaireBox = Hive.box<Inventaire>(Constant.hiveInventaireBox);
    await Hive.box<InventaireItem>(
      Constant.hiverayonInventaireItemsBox,
    ).clear();

    _inventaires = null;
    notifyListeners();
  }
}
