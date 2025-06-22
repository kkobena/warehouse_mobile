
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/produit/produit_service.dart';
import 'package:warehouse_mobile/src/models/produit/produit.dart';

class ProductSearchPage extends StatefulWidget {
  static const String routeName = '/produit';
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  Produit? _selectedProduit; // To store the selected product for detail display
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentSearchTerm = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize or fetch data here if needed
    });
  }
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({String? searchTerm}) async {
    // Use the provided searchTerm, or the controller's text, or the last search term
    final String query = searchTerm ?? _textEditingController.text;
    if (!mounted) return;

    // Get the ProduitService instance from Provider
    final produitService = Provider.of<ProduitService>(context, listen: false);

    await produitService.fetchAll(query);

    // Update the current search term if the fetch was initiated by a new search
    if (searchTerm != null || query != _currentSearchTerm) {
      if (mounted) {
        setState(() {
          _currentSearchTerm = query;
        });
      }
    }
  }


  Widget _buildProduitSuggestionTile(
    BuildContext context,
    Produit produit,
    VoidCallback onTap,
  ) {
    final Color titleColor =
        Theme.of(context).textTheme.titleLarge?.color ??
        Theme.of(context).colorScheme.onSurface;
    final Color? itemTextColor = Theme.of(context).textTheme.bodyMedium?.color;

    return ListTile(
      leading: Icon(Icons.inventory_2_outlined),
      // title:   Text(produit.name),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                produit.libelle,
                style: TextStyle(fontSize: 15, color: itemTextColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 3,
              child: Text(
                produit.codeCip!,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: itemTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // subtitle: Text('Qty: ${produit.quantity ?? "N/A"} • Price: ${produit.unitPrice ?? "N/A"}'),
      onTap: onTap, // onTap will be provided by Autocomplete's optionsViewBuilder
    );
  }




  @override
  Widget build(BuildContext context) {
    final produitService = Provider.of<ProduitService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Autocomplete Search Field ---
            Autocomplete<Produit>(
              // displayStringForOption: (Produit option) => option.name, // Correct
              displayStringForOption: (Produit option) { // Added for clarity
                return option.libelle;
              },
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.trim().isEmpty) {
                  return const Iterable<Produit>.empty();
                }

                await produitService.fetchAll(textEditingValue.text);
                if (produitService.errorMessage.isNotEmpty) {

                  return const Iterable<Produit>.empty();
                }
                return produitService.items ?? const Iterable<Produit>.empty();
              },
              onSelected: (Produit selection) {
                setState(() {
                  _selectedProduit = selection;
                  // Optional: Clear the text field or keep the selected name
                  _textEditingController.text = selection.libelle; // Keep name in field
                  //_textEditingController.clear(); // Or clear it
                  _focusNode.unfocus(); // Unfocus to hide keyboard and options
                });
                print('Selected: ${selection.libelle}');
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {


                return TextField(
                  controller: fieldTextEditingController, // Use Autocomplete's controller
                  focusNode: fieldFocusNode,             // Use Autocomplete's focus node
                  decoration: InputDecoration(
                    hintText: 'Enter product name...',
                    labelText: 'Search Product',
                    border: OutlineInputBorder(),
                    suffixIcon: fieldTextEditingController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        fieldTextEditingController.clear();
                        setState(() {
                          _selectedProduit = null; // Clear details if search is cleared
                        });
                      },
                    )
                        : null,
                  ),
                  onSubmitted: (String value) {
                    onFieldSubmitted(); // Important for accessibility & keyboard actions
                  },
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<Produit> onSelected,
                  Iterable<Produit> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 250), // Limit height of suggestions
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Produit option = options.elementAt(index);
                          // Use a widget to display each product suggestion
                          return _buildProduitSuggestionTile(
                            context,
                            option,
                                () => onSelected(option), // Call onSelected when tapped
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- Detail Display Section ---
            if (_selectedProduit != null)
              Expanded( // Use Expanded if you want details to take remaining space
                child: ProduitDetailWidget(produit: _selectedProduit!), // Your detail widget
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Select a product to see details.', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
class ProduitDetailWidget extends StatelessWidget {
  final Produit produit;

  const ProduitDetailWidget({Key? key, required this.produit}) ;

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Make details scrollable if they are long
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                produit.libelle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildDetailRow('ID:', produit.id.toString() ?? 'N/A'),
              _buildDetailRow('Quantity:', produit.totalQuantity?.toString() ?? 'N/A'),
              _buildDetailRow('Unit Price:', produit.regularUnitPrice.toString() ?? 'N/A'),
              // _buildDetailRow('Gross Amount:', produit.grossAmount ?? 'N/A'),

              // Example for showing related data (conceptual)
              // if (produit.commdes != null && produit.commdes!.isNotEmpty) ...[
              //   SizedBox(height: 16),
              //   Text("Recent Orders:", style: Theme.of(context).textTheme.titleMedium),
              //   ...produit.commdes!.take(3).map((c) => ListTile(title: Text("Order ${c.id}"))),
              // ],
              // Add more details as needed from your ProduitDetailBody design
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}