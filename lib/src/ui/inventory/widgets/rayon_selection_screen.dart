import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/inventaire/rayon_service.dart';
import 'package:warehouse_mobile/src/models/inventaire/rayon.dart';
import 'package:warehouse_mobile/src/ui/inventory/widgets/inventory_entry_screen.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/custom_app_bar.dart';

class RayonSelectionScreen extends StatefulWidget {
  final int
  inventoryContextId; // Example: ID of the current inventory operation

  const RayonSelectionScreen({
    super.key,
    required this.inventoryContextId, // Or however you get this ID
  });

  @override
  State<RayonSelectionScreen> createState() => _RayonSelectionScreenState();
}

class _RayonSelectionScreenState extends State<RayonSelectionScreen> {
  late RayonService _rayonService; // To store the service instance

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding.instance.addPostFrameCallback to call service after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Obtain the service instance once
        _rayonService = Provider.of<RayonService>(context, listen: false);

        _rayonService.fetchAll(widget.inventoryContextId).catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur initiale chargement rayons: $error',
                  style: Constant.getErrorTextStyle(),
                ),
              ),
            );
          }
        });
      }
    });
  }

  Future<void> _refreshRayons() async {
    if (mounted) {
      try {
        await _rayonService.fetchAll(widget.inventoryContextId);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur rafraîchissement rayons: $error',
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
    // Use Consumer to listen to changes in RayonService
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: const Text('Sélectionner un Rayon'),
        onRefreshTap: () => _refreshRayons,
      ),

      body: Consumer<RayonService>(
        builder: (context, rayonService, child) {
          // Update local service instance if it changed (e.g., due to provider recreation)
          // This is generally not needed if the provider is stable above this widget.
          _rayonService = rayonService;

          if (rayonService.isLoading && rayonService.rayons == null) {
            // Show loading only on initial load
            return const Center(child: CircularProgressIndicator());
          }

          if (rayonService.errorMessage.isNotEmpty &&
              rayonService.rayons == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      rayonService.errorMessage,
                      style: Constant.getErrorTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshRayons,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (rayonService.rayons == null || rayonService.rayons!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aucun rayon trouvé.',
                      style: Constant.getErrorTextStyle(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshRayons,
                      child: const Text('Rafraîchir'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Display the list of rayons
          return RefreshIndicator(
            onRefresh: _refreshRayons,
            child: ListView.builder(
              itemCount: rayonService.rayons!.length,
              itemBuilder: (context, index) {
                final Rayon rayon = rayonService.rayons![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      rayon.libelle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Code: ${rayon.code}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InventoryEntryScreen(rayon: rayon),
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
    );
  }
}
