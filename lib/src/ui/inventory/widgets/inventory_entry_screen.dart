import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/inventaire/item_service.dart';
import 'package:warehouse_mobile/src/models/inventaire/rayon.dart';
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
  ItemService? _itemService; // Store service instance

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Good practice, though often not strictly needed for Provider.of here
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

  // Helper to get service, ensuring it's initialized and widget is mounted
  ItemService? get _safeService {
    if (!mounted) return null;

    return _itemService ?? Provider.of<ItemService>(context, listen: false);
  }

  void _submitQuantityAndMoveNext([String? valueFromTextField]) {
    final service = _safeService; // Use the getter
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
    final service = _safeService; // Use the getter
    if (service == null ||
        service.currentItemToInventory == null ||
        service.isInventoryCompleted) {
      return;
    }
    // Save current before going back if value exists and item is valid
    final currentQtyText = _quantityController.text;
    if (currentQtyText.isNotEmpty) {
      final int? quantity = int.tryParse(currentQtyText);
      service.updateCurrentItemQuantity(quantity); // Save current edits
    }
    service.moveToPreviousItem();
  }

  void _showCompletionDialog(ItemService service) {
    if (!mounted) return; // Guard before showing the dialog

    showDialog(
      context: context, // This context is for the InventoryEntryScreen
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        // dialogContext is for the AlertDialog
        title: const Text('Inventaire Terminé'),
        content: Text(
          'L\'inventaire pour le rayon "${widget.rayon.libelle}" est terminé.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Synchroniser et Fermer'),
            onPressed: () async {
              // Pop the dialog first using its own context
              Navigator.of(dialogContext).pop();

              if (!mounted) {
                return; // Check if InventoryEntryScreen is still mounted
              }

              ScaffoldMessenger.of(context).showSnackBar(
                // Uses InventoryEntryScreen's context
                const SnackBar(content: Text('Synchronisation en cours...')),
              );

              bool success = await service.synchronizeItemsForRayon(
                widget.rayon.id,
              );

              if (!mounted) return; // Re-check after await

              ScaffoldMessenger.of(
                context,
              ).removeCurrentSnackBar(); // Uses InventoryEntryScreen's context
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  // Uses InventoryEntryScreen's context
                  const SnackBar(
                    content: Text('Synchronisation réussie!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(); // Pop InventoryEntryScreen
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  // Uses InventoryEntryScreen's context
                  SnackBar(
                    content: Text(
                      'Échec de la synchronisation: ${service.errorMessage}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          TextButton(
            child: const Text('Fermer (Sans Synchroniser)'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Pop the dialog
              if (mounted) {
                // Check before popping the main screen
                Navigator.of(context).pop(); // Pop InventoryEntryScreen
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemService>(
      builder: (context, service, child) {
        // Storing the service instance from Consumer's builder if _itemService wasn't set.
        // This is mainly for methods outside build, like _submitQuantityAndMoveNext.
        _itemService ??= service;

        final currentItem = service.currentItemToInventory;

        // This block is within the build method, 'mounted' is implicitly true here.
        // The addPostFrameCallback handles its own 'mounted' check for async UI work.
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
          // This WidgetsBinding call is fine. The inner checks are good.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && ModalRoute.of(context)?.isCurrent == true) {
              _quantityFocusNode.requestFocus();
              SystemChannels.textInput.invokeMethod('TextInput.show');
            }
          });
        } else if (service.isInventoryCompleted && !service.isLoading) {
          // This WidgetsBinding call is fine. The inner checks are good.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check if a dialog isn't already up (e.g. if build is called multiple times rapidly)
            // and if the current screen is still the top-most modal route.
            bool isDialogAlreadyShown = Navigator.of(
              context,
              rootNavigator: true,
            ).canPop();
            // A more robust check might involve managing a flag like _isDialogShowing.
            // The canPop check is a bit of a heuristic.

            if (mounted &&
                ModalRoute.of(context)?.isCurrent == true &&
                !isDialogAlreadyShown &&
                ModalRoute.of(context)
                    is! PopupRoute // Ensure it's not a dialog itself causing canPop
                    ) {
              // Pass the service instance obtained from Consumer
              _showCompletionDialog(service);
            }
          });
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
              ? Center(child: Text(service.errorMessage,style: Constant.getErrorTextStyle()))
              : service.isInventoryCompleted
              ? Center(
                  /* ... Completion UI ... */
                  child: Padding(
                    // Added from original for consistency
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Comptage pour  "${widget.rayon.libelle}" terminé!',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          // Pass the service instance from Consumer
                          onPressed: () => _showCompletionDialog(service),
                          child: const Text('Terminer et Synchroniser'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (mounted) {
                              // Good practice before navigation
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Retour (Sans Synchroniser)'),
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
              : Padding(

                  padding: const EdgeInsets.all(8.0), // Added from original
                  child: SingleChildScrollView(
                    // Added from original
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
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Code: ${currentItem.produitCips}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall,
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
