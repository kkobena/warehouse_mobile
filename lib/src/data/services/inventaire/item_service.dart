import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_mobile/src/models/inventaire/inventaire_item.dart';
import 'package:warehouse_mobile/src/models/inventaire/rayon.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/service/shared_service.dart';
import 'package:warehouse_mobile/src/utils/service_state_wrapper.dart';

class ItemService extends BaseServiceNotifier {
  final SharedService _sharedService;
  late Box<InventaireItem> _inventaireItemBox;
  bool _isServiceLoading = false; // Renamed to avoid clash with UI loading
  String _serviceErrorMessage = ''; // Renamed
  List<Rayon> _rayonsList = []; // In-memory list for UI, kept in sync with Hive


  List<InventaireItem> _currentInventorySessionItems = [];
  int _currentInventoryIndex = 0;

  // Public getters for UI
  List<InventaireItem> get itemsForCurrentRayonInventory =>
      _currentInventorySessionItems;

  int get currentItemIndex => _currentInventoryIndex;

  InventaireItem? get currentItemToInventory =>
      _currentInventorySessionItems.isNotEmpty &&
          _currentInventoryIndex < _currentInventorySessionItems.length
      ? _currentInventorySessionItems[_currentInventoryIndex]
      : null;

  bool get isInventoryCompleted =>
      _currentInventorySessionItems.isNotEmpty &&
      _currentInventoryIndex >= _currentInventorySessionItems.length;

  @override
  bool get isLoading => _isServiceLoading; // Use the renamed internal variable

  @override
  String get errorMessage => _serviceErrorMessage; // Use the renamed internal variable

  @override
  bool get hasData => _currentInventorySessionItems.isNotEmpty;

  // To manage loading state specifically for the inventory screen operations
  bool _isInventoryScreenLoading = false;

  bool get isInventoryScreenLoading => _isInventoryScreenLoading;
  List<Rayon> get rayons => _rayonsList;
  ItemService() : _sharedService = SharedService() {
    _initBox();
  }
  Box<Rayon> get _rayonsBox {
    return Hive.box<Rayon>(Constant.hiveRayonBox);
  }

  Future<void> _loadRayonsFromHive() async {
    _rayonsList = _rayonsBox.values.toList();
    notifyListeners();

  }
  List<InventaireItem> getAllItems(int rayonId,int  idInventaire) {

    return _inventaireItemBox.values.toList()
        .where(
          (item) =>
      item.rayonId == rayonId &&
          item.storeInventoryId == idInventaire,
    )
        .toList();
  }
  Future<void> _initBox() async {
    // Ensure adapter is registered (ideally in main.dart or app startup)
    if (!Hive.isAdapterRegistered(InventaireItemAdapter().typeId)) {
      // Assuming typeId 1
      Hive.registerAdapter(InventaireItemAdapter());
    }
    if (!Hive.isBoxOpen(Constant.hiverayonInventaireItemsBox)) {
      _inventaireItemBox = await Hive.openBox<InventaireItem>(
        Constant.hiverayonInventaireItemsBox,
      );
    } else {
      _inventaireItemBox = Hive.box<InventaireItem>(
        Constant.hiverayonInventaireItemsBox,
      );
    }
  }
  void markRayonAsSynchronized(int rayonId) async{
    final rayon = _rayonsBox.get(rayonId);
    if (rayon != null) {
      rayon.isSynchronized = true;
      await rayon.save(); // Save the change back to Hive

      await _loadRayonsFromHive(); // Refresh in-memory list and notify UI
    }
  }
  Future<void> prepareInventoryItemsForRayon(
    int idRayon,
    int idInventaire,
  ) async {
    _isInventoryScreenLoading = true;
    _serviceErrorMessage = '';
    notifyListeners();

    try {
      // Attempt to load from Hive first, specific to the rayon.
      // You might need a more sophisticated way to know if items for 'idInventaire' on 'idRayon'
      // are already in the box without fetching ALL items from the box.
      // For simplicity, let's assume _loadFromHiveForRayon filters or fetches relevant items.
      List<InventaireItem>? itemsFromHive = await _loadFromHiveForRayon(
        idRayon,
        idInventaire,
      );

      if (itemsFromHive != null && itemsFromHive.isNotEmpty) {
        _currentInventorySessionItems = List.from(
          itemsFromHive,
        ); // Create a mutable copy
      } else {
        await _sharedService.fetchListData<InventaireItem>(
          endpoint: '/mobile/inventories/rayons/$idRayon/items/$idInventaire',
          itemParserFromJson: (jsonData) => InventaireItem.fromJson(jsonData),
          setLoading: (loading) => _isServiceLoading = loading,
          // Main service loading for API call
          setError: (error) => _serviceErrorMessage = error,
          notifyListenersCallback: notifyListeners,
          // Notifies for API call state
          saveListToHive: (items) async {
            await _saveAllToHive(items); // Save to the general box
            _currentInventorySessionItems = List.from(
              items,
            ); // Update session items
          },
          loadListFromHive: () async {
            final allBoxItems = _inventaireItemBox.values.toList();

            return allBoxItems
                .where(
                  (item) =>
                      item.rayonId == idRayon &&
                      item.storeInventoryId == idInventaire,
                )
                .toList();
          },
          forceRefresh: false,
        );
        // If fetchListData successfully fetched and saved, _currentInventorySessionItems should be populated.
        // If it loaded from its cache (which might be the full box), we might need to re-filter here.
        // To be safe after fetchAll:
        if (_currentInventorySessionItems.isEmpty) {
          // If saveListToHive inside fetchList didn't set it properly
          final allBoxItems = _inventaireItemBox.values.toList();
          _currentInventorySessionItems = allBoxItems
              .where(
                (item) =>
                    item.rayonId == idRayon &&
                    item.storeInventoryId == idInventaire,
              )
              .toList();
        }
      }
      _currentInventoryIndex = 0;
    } catch (e) {
      _serviceErrorMessage = "Erreur préparation inventaire: ${e.toString()}";
    } finally {
      _isInventoryScreenLoading = false;
      notifyListeners();
    }
  }

  Future<List<InventaireItem>?> _loadFromHiveForRayon(
    int idRayon,
    int idInventaire,
  ) async {
    // Assuming InventaireItem has rayonId and inventaireId properties
    final items = _inventaireItemBox.values
        .where(
          (item) =>
              item.rayonId == idRayon && item.storeInventoryId == idInventaire,
        )
        .toList();
    return items.isNotEmpty ? items : null;
  }

  Future<void> _saveAllToHive(List<InventaireItem> data) async {
    // This is used by fetchListData
    for (var item in data) {
      await _inventaireItemBox.put(
        item.id,
        item,
      ); // Use a unique key, e.g. item.id
    }
  }


  Future<void> updateCurrentItemQuantity(int? quantity) async {
    if (currentItemToInventory != null) {
      InventaireItem updatedItem = currentItemToInventory!;
      updatedItem.quantityOnHand = quantity; // Update the quantity
      updatedItem.isDirty = true; // Mark as needing sync
      updatedItem.updated = true;

      await _inventaireItemBox.put(updatedItem.id, updatedItem); // Save to Hive

      // Update the item in the local list as well
      _currentInventorySessionItems[_currentInventoryIndex] = updatedItem;
    }
  }

  void moveToNextItem() {
    if (!isInventoryCompleted) {
      _currentInventoryIndex++;
      notifyListeners();
    }
  }

  void moveToPreviousItem() {
    if (_currentInventoryIndex > 0) {
      _currentInventoryIndex--;
      notifyListeners();
    }
  }

  Future<bool> synchronizeItemsForRayon(int rayonId) async {
    _isServiceLoading = true;
    _serviceErrorMessage = '';
    notifyListeners();

    final List<InventaireItem> items = _currentInventorySessionItems
        .where(
          (item) => item.rayonId == rayonId,
        ) // Ensure they belong to the rayon
        .toList();
    print('Synchronizing ${items.length} items for rayon $rayonId');

    if (items.isEmpty) {
      _serviceErrorMessage = 'Aucun élément à synchroniser pour ce rayon.';
      _isServiceLoading = false;
      notifyListeners();
      return true; // Nothing to do
    }

    try {
      final List<Map<String, dynamic>> jsonDataList = items
          .map((item) => item.toJson())
          .toList();

      final http.Response? response = await _sharedService.postListData(
        endpoint: '/mobile/inventories/items/synchronize',
        jsonDataList: jsonDataList,
        setLoading: (loading) {
          /* _isServiceLoading = loading; */
        },
        // Outer method handles this
        setError: (error) {
          /* _serviceErrorMessage = error; */
        },
        // Outer method handles this
        notifyListenersCallback: () {
          /* notifyListeners(); */
        }, // Outer method handles this
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 202)) {
        _serviceErrorMessage = '';

        for (var syncedItem in items) {
          syncedItem.isDirty = false;
          await _inventaireItemBox.put(syncedItem.id, syncedItem);
        }
         markRayonAsSynchronized(rayonId); // Mark rayon as synchronized
        _isServiceLoading = false;
        notifyListeners();
        return true;
      } else {
        if (response != null) {
          _serviceErrorMessage =
              'Erreur de synchronisation (Code: ${response.statusCode}). ${response.body}';
        } else {
          _serviceErrorMessage = 'Erreur de synchronisation inconnue.';
        }
        _isServiceLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _serviceErrorMessage = 'Erreur inattendue lors de la synchronisation: $e';
      _isServiceLoading = false;
      notifyListeners();
      return false;
    }
  }
}
