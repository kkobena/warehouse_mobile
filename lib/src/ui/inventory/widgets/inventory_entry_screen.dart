import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/inventaire/item_service.dart';
import 'package:warehouse_mobile/src/models/inventaire/rayon.dart';
import 'package:warehouse_mobile/src/ui/inventory/widgets/rayon_item_resume.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/custom_app_bar.dart';

class InventoryEntryScreen extends StatefulWidget {
  final Rayon rayon;

  const InventoryEntryScreen({super.key, required this.rayon});

  @override
  State<InventoryEntryScreen> createState() => _InventoryEntryScreenState();
}

class _InventoryEntryScreenState extends State<InventoryEntryScreen> {
  final _quantityController = TextEditingController();
  final _quantityFocusNode = FocusNode();
  ItemService? _itemService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _itemService = Provider.of<ItemService>(context, listen: false);
        _itemService?.prepareInventoryItemsForRayon(
          widget.rayon.id,
          widget.rayon.inventoryId,
        );
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  ItemService? get _safeService {
    if (!mounted) return null;
    return _itemService ?? Provider.of<ItemService>(context, listen: false);
  }

  void _submitQuantityAndMoveNext([String? valueFromTextField]) {
    final service = _safeService;
    if (service == null ||
        service.currentItemToInventory == null ||
        service.isInventoryCompleted) {
      return;
    }
    final String quantityText = valueFromTextField ?? _quantityController.text;
    final int? quantity = int.tryParse(quantityText);
    service.updateCurrentItemQuantity(quantity).then((_) {
      if (mounted) {
        service.moveToNextItem();
      }
    });
  }

  void _handlePrevious() {
    final service = _safeService;
    if (service == null ||
        service.currentItemToInventory == null ||
        service.isInventoryCompleted) {
      return;
    }
    final currentQtyText = _quantityController.text;
    if (currentQtyText.isNotEmpty) {
      final int? quantity = int.tryParse(currentQtyText);
      service.updateCurrentItemQuantity(quantity);
    }
    service.moveToPreviousItem();
  }

  void _hideKeyboard() {
    _quantityFocusNode.unfocus();
  }

  // This method is now called from the "Completed" UI directly
  // or after navigating back from the Resume screen.
  Future<void> _synchronizeDirectly(ItemService service) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation en cours...')),
    );

    bool success = await service.synchronizeItemsForRayon(widget.rayon.id);


    if (!mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Synchronisation réussie!'),
          backgroundColor: Colors.green[300] ?? Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Pop InventoryEntryScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la synchronisation: ${service.errorMessage}'),
          backgroundColor: Colors.red[300] ?? Colors.red,
        ),
      );
    }
  }

  // The original _showCompletionDialog is no longer needed in the same way,
  // as the "completed" UI will now offer "View Resume" or "Sync Directly".
  // We can simplify or remove it. For now, I'll remove it as the logic moves to the UI.

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemService>(
      builder: (context, service, child) {
        _itemService ??= service;
        final currentItem = service.currentItemToInventory;

        if (!service.isInventoryScreenLoading &&
            currentItem != null &&
            !service.isInventoryCompleted) {
          final currentQtyText = currentItem.quantityOnHand?.toString() ?? "";
          if (_quantityController.text != currentQtyText) {
            _quantityController.text = currentQtyText;
            _quantityController.selection = TextSelection.fromPosition(
              TextPosition(offset: _quantityController.text.length),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && ModalRoute.of(context)?.isCurrent == true) {
              _quantityFocusNode.requestFocus();
              // SystemChannels.textInput.invokeMethod('TextInput.show'); // Usually optional
            }
          });
        } else if (service.isInventoryCompleted && !service.isLoading) {
          if (_quantityFocusNode.hasFocus) {
            _hideKeyboard();
          }
          // No automatic dialog popup here anymore. The UI will handle options.
        }

        return Scaffold(
          appBar: CustomAppBar(
            titleWidget: Text(widget.rayon.libelle),
            bottomWidget: service.itemsForCurrentRayonInventory.isNotEmpty &&
                !service.isInventoryCompleted
                ? PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: service.itemsForCurrentRayonInventory.isEmpty
                    ? 0
                    : (service.currentItemIndex) /
                    service.itemsForCurrentRayonInventory.length,
                backgroundColor: Colors.grey[300],
              ),
            )
                : null,
          ),
          body: service.isInventoryScreenLoading
              ? const Center(
            child: CircularProgressIndicator(
              key: ValueKey("loadingIndicator"),
            ),
          )
              : service.errorMessage.isNotEmpty &&
              service.itemsForCurrentRayonInventory.isEmpty
              ? Center(
            child: Text(
              service.errorMessage,
              style: Constant.getErrorTextStyle(),
            ),
          )
              : service.isInventoryCompleted
              ? Center( // UI for when inventory counting is done
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 16), // Increased spacing
                  Text(
                    'Comptage pour "${widget.rayon.libelle}" terminé!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18), // Adjusted font size
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24), // Increased spacing
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Voir le Résumé'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RayonItemResume(
                              rayon: widget.rayon,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12), // Spacing between buttons
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text('Synchroniser Directement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Different color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _synchronizeDirectly(service),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop(); // Pop InventoryEntryScreen
                      }
                    },
                    child: const Text('Fermer (Sans Synchroniser)'),
                  ),
                ],
              ),
            ),
          )
              : currentItem == null
              ? const Center(
            child: Text(
              'Aucun article à inventorier dans ce rayon ou inventaire terminé.',
            ),
          )
              : Padding( // Item entry UI
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Article: ${service.currentItemIndex + 1}/${service.itemsForCurrentRayonInventory.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentItem.produitLibelle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Code: ${currentItem.produitCips}', // Assuming 'produitCips' is correct
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey(currentItem.id),
                    controller: _quantityController,
                    focusNode: _quantityFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Quantité inventoriée',
                      border: OutlineInputBorder(),
                      hintText: 'Entrez la quantité',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      _submitQuantityAndMoveNext(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Précédent'),
                        onPressed: service.currentItemIndex > 0
                            ? _handlePrevious
                            : null,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Suivant'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          _submitQuantityAndMoveNext();
                        },
                      ),
                    ],
                  ),
                  if (service.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
