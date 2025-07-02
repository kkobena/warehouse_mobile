import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/inventaire/inventaire_service.dart';
import 'package:warehouse_mobile/src/models/inventaire/inventaire.dart';
import 'package:warehouse_mobile/src/ui/inventory/widgets/rayon_selection_screen.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/custom_app_bar.dart';

class InventoryPage extends StatefulWidget {
  static const String routeName = '/inventaire';
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventaireSelectionScreenState();
}

class _InventaireSelectionScreenState extends State<InventoryPage> {
  late InventaireService _inventaireService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inventaireService = Provider.of<InventaireService>(
          context,
          listen: false,
        );
        // Fetch all inventories. The service's fetchAll() doesn't take an ID.
        _inventaireService.fetchAll().catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur initiale chargement inventaires: $error',
                  style: Constant.getErrorTextStyle(),
                ),
              ),
            );
          }
        });
      }
    });
  }

  Future<void> _refreshInventaires() async {
    if (mounted) {
      try {
        await _inventaireService.refresh();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur rafraîchissement inventaires: $error',
                style: Constant.getErrorTextStyle(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: const Text('Sélectionner un Inventaire'),
        onRefreshTap: _refreshInventaires
      ),
      body: Consumer<InventaireService>(
        builder: (context, inventaireService, child) {
          // Update local service instance (generally not needed if provider is stable)
          _inventaireService = inventaireService;

          if (inventaireService.isLoading &&
              (inventaireService.inventaires == null ||
                  inventaireService.inventaires!.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (inventaireService.errorMessage.isNotEmpty &&
              (inventaireService.inventaires == null ||
                  inventaireService.inventaires!.isEmpty)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      inventaireService.errorMessage,
                      textAlign: TextAlign.center,
                      style: Constant.getErrorTextStyle(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshInventaires,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (inventaireService.inventaires == null ||
              inventaireService.inventaires!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aucun inventaire trouvé.',
                      style: Constant.getErrorTextStyle(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshInventaires,
                      child: const Text('Rafraîchir'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Display the list of inventaires
          return RefreshIndicator(
            onRefresh: _refreshInventaires,
            child: ListView.builder(
              itemCount: inventaireService.inventaires!.length,
              itemBuilder: (context, index) {
                final Inventaire inventaire =
                    inventaireService.inventaires![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      // Display status with color, example
                      backgroundColor: _getStatusColor(inventaire.statut),
                      child: Text(
                        _getStatus(
                          inventaire.statut,
                        ).substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      inventaire.description,
                      // Use a default if libelle can be null
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (inventaire.createdAt != null)
                          Text(
                            'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(inventaire.createdAt!)}',
                          ),
                        if (inventaire.statut != null)
                          Text(
                            'Statut: ${_getStatus(inventaire.statut)}'

                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Only allow selection if inventory is in an "open" or "ongoing" state
                      // Adjust this condition based on your actual status values
                      if (inventaire.statut == 'CREATE' ||
                          inventaire.statut?.toLowerCase() == 'PROCESSING') {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RayonSelectionScreen(
                                // Pass the selected Inventaire's ID
                                // This ID will be used by RayonService.fetchAll(id)
                                inventoryContextId: inventaire.id,
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cet inventaire (statut: ${inventaire.statut}) ne peut pas être sélectionné.',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<InventaireService>(
          context,
          listen: false,
        ).cleanHive(),
        tooltip: 'Supprimer les données locales',

        child: const Icon(Icons.delete_forever),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'CREATE':
        return Colors.green[300] ?? Colors.green;
      case 'PROCESSING':
        return Colors.blue[300] ?? Colors.blue;
      case 'CLOSED':
        return Colors.red[300] ?? Colors.red;

      default:
        return Colors.grey;
    }
  }

  String _getStatus(String? status) {
    switch (status) {
      case 'CREATE':
        return "ouvert";
      case 'PROCESSING':
        return "En cours";
      case 'CLOSED':
        return "Terminé";

      default:
        return "Statut inconnu";
    }
  }
}
