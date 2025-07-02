import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/inventaire/item_service.dart';
import 'package:warehouse_mobile/src/models/inventaire/inventaire_item.dart';
import 'package:warehouse_mobile/src/models/inventaire/rayon.dart';
import 'package:warehouse_mobile/src/utils/custom_app_bar.dart';

class RayonItemResume extends StatefulWidget {
  final Rayon rayon;

  const RayonItemResume({super.key, required this.rayon});

  @override
  State<RayonItemResume> createState() => _RayonItemResumeState();
}

class _RayonItemResumeState1 extends State<RayonItemResume> {
  bool _isSynchronizing = false;

  Future<void> _synchronizeAndClose(ItemService service) async {
    // Removed BuildContext from params
    if (!mounted) return;

    setState(() {
      _isSynchronizing = true;
    });

    // Use this.context here, it's safe because we checked mounted above
    ScaffoldMessenger.of(context).showSnackBar(
      // 'context' here now refers to this.context
      const SnackBar(content: Text('Synchronisation en cours...')),
    );

    bool success = await service.synchronizeItemsForRayon(widget.rayon.id);

    // Crucial: Check if the widget is still in the tree AFTER the await.
    if (!mounted) return; // This check is vital!

    // Use this.context for operations after the await, guarded by the mounted check
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Synchronisation réussie!'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        // Secondary mounted check before navigation is good practice
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la synchronisation: ${service.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSynchronizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    // Renamed to buildContext for clarity if needed
    final itemService = Provider.of<ItemService>(buildContext, listen: false);
    final itemsToReview = itemService.itemsForCurrentRayonInventory
        .where((item) => item.quantityOnHand != null)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Résumé: ${widget.rayon.libelle}')),
      body: Column(
        children: [
          Expanded(
            child: itemsToReview.isEmpty
                ? const Center(
                    child: Text('Aucun article n\'a été compté dans ce rayon.'),
                  )
                : ListView.builder(
                    itemCount: itemsToReview.length,
                    itemBuilder: (context, index) {
                      // This 'context' is local to itemBuilder
                      final InventaireItem item = itemsToReview[index];
                      return ListTile(
                        title: Text(item.produitLibelle),
                        trailing: Text(
                          'Qté: ${item.quantityOnHand}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Total articles comptés: ${itemsToReview.length}",
                  textAlign: TextAlign.center,
                  style: Theme.of(buildContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: _isSynchronizing
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _isSynchronizing
                        ? 'Synchronisation...'
                        : 'Synchroniser et Fermer',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSynchronizing
                      ? null
                      : () => _synchronizeAndClose(
                          itemService,
                        ), // Pass only service
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _isSynchronizing
                      ? null
                      : () {
                          // Use 'context' from the build method, or this.context if within the State class scope
                          if (Navigator.canPop(buildContext)) {
                            // Using buildContext from build method
                            Navigator.of(buildContext).pop();
                          }
                        },
                  child: const Text('Retourner au comptage'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RayonItemResumeState extends State<RayonItemResume> {
  bool _isSynchronizing = false;

  Future<void> _synchronizeAndClose(ItemService service) async {
    // --- Add this check at the beginning ---
    if (widget.rayon.isSynchronized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ce rayon est déjà synchronisé.')),
      );
      // Optionally, just pop if the user somehow got here with a synced rayon
      // and tried to press a (now should be disabled) sync button.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }
    // --- End added check ---

    if (!mounted) return;
    setState(() {
      _isSynchronizing = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation en cours...')),
    );

    bool success = await service.synchronizeItemsForRayon(widget.rayon.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (success) {
      // service.synchronizeItemsForRayon will now call markRayonAsSynchronized
      // which will update the Rayon object in the ItemService's list
      // and notifyListeners, causing RayonSelectionScreen to rebuild.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Synchronisation réussie!'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la synchronisation: ${service.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isSynchronizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    final itemService = Provider.of<ItemService>(buildContext, listen: false);

    final itemsToReview = itemService.itemsForCurrentRayonInventory
        .where((item) => item.quantityOnHand != null)
        .toList();

    final currentRayonFromService = itemService.rayons.firstWhere(
      (r) => r.id == widget.rayon.id,
      orElse: () => widget
          .rayon, // Fallback to widget.rayon if not found, though it should be
    );
    final bool isActuallySynchronized = currentRayonFromService.isSynchronized;
    final items = isActuallySynchronized
        ? itemService.getAllItems(widget.rayon.id, widget.rayon.inventoryId)
        : [];

    return Scaffold(
      appBar:CustomAppBar(
        titleWidget:Text(
          'Résumé: ${widget.rayon.libelle} ${isActuallySynchronized ? "(Synchronisé)" : ""}',
        ) ,
      ),
      

      body: Column(
        // ... (ListView for itemsToReview) ...
        children: [
          Expanded(
            child:
                itemsToReview.isEmpty &&
                    items.isEmpty // Only show if not synced and no items
                ? const Center(
                    child: Text('Aucun article n\'a été compté dans ce rayon.'),
                  )
                /* : itemsToReview.isEmpty && isActuallySynchronized
                ? const Center(
              child: Text('Ce rayon est synchronisé. Les données sont à jour.'),
            )*/
                : ListView.builder(
                    itemCount: !isActuallySynchronized
                        ? itemsToReview.length
                        : items.length,
                    itemBuilder: (context, index) {
                      final InventaireItem item = !isActuallySynchronized
                          ? itemsToReview[index]
                          : items[index];
                      return ListTile(
                        title: Text(item.produitLibelle),
                        trailing: Text(
                          'Qté: ${item.quantityOnHand}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!itemsToReview
                    .isEmpty) // Only show count if there are items reviewed now
                  Text(
                    "Total articles comptés: ${itemsToReview.length}",
                    textAlign: TextAlign.center,
                    style: Theme.of(buildContext).textTheme.titleMedium,
                  ),
                const SizedBox(height: 16),
                // Disable or change button if already synchronized
                if (!isActuallySynchronized) // Only show sync button if not already synced
                  ElevatedButton.icon(
                    icon: _isSynchronizing
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      _isSynchronizing
                          ? 'Synchronisation...'
                          : 'Synchroniser et Fermer',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSynchronizing
                        ? null
                        : () => _synchronizeAndClose(itemService),
                  )
                else // If already synchronized, maybe show a different button or just "Close"
                  ElevatedButton(
                    child: const Text('Fermer'),
                    onPressed: () {
                      if (Navigator.canPop(context))
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                    },
                  ),
                const SizedBox(height: 8),
                // The "Retourner au comptage" button might be irrelevant if already synchronized
                // or if no items are being actively counted.
                if (!isActuallySynchronized && itemsToReview.isNotEmpty)
                  OutlinedButton(
                    child: const Text('Retourner au comptage'),
                    onPressed: _isSynchronizing
                        ? null
                        : () {
                            if (Navigator.canPop(buildContext)) {
                              Navigator.of(buildContext).pop();
                            }
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
