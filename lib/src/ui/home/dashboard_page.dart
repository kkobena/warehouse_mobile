import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/dahboard/dashboard_sale_service.dart';
import 'package:warehouse_mobile/src/data/services/dahboard/model/dashboard.dart';
import 'package:warehouse_mobile/src/models/pair_model.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    Key? key,
    // required this.features
  }) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();

  // Fonction pour afficher le DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // Date initialement sélectionnée dans le picker
      firstDate: DateTime(2024),
      // Date la plus ancienne sélectionnable
      lastDate: DateTime.now(),

      // Date la plus récente sélectionnable
      locale: const Locale('fr', 'FR'), // Exemple pour le français
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

      });
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<DashboardSaleService>().fetchDashboard( DateFormat('y-MM-dd').format(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      DateFormat.YEAR_MONTH_DAY,
      'fr_FR', // Format de date en français
    ).format(_selectedDate);
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final HSLColor hslPrimary = HSLColor.fromColor(primaryColor);
    double lightnessIncrease = 0.25;
    final HSLColor hslLighterPrimary = hslPrimary.withLightness(
        (hslPrimary.lightness +lightnessIncrease).clamp(0.0, 1.0)
    );
    final Color lighterPrimaryColor = hslLighterPrimary.toColor();


    final Color gradientStart = primaryColor;
    final Color gradientEnd = lighterPrimaryColor;
    Color gradientForegroundColor = Theme.of(context).colorScheme.onPrimary;
    const Color gradientForeground = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 0, // Optional: remove shadow if the gradient looks better without it
        foregroundColor: gradientForeground,    // Set foreground for text/icons
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[gradientStart, gradientEnd],
              begin: Alignment.topLeft,   // Gradient start position
              end: Alignment.bottomRight, // Gradient end position
              // stops: [0.0, 1.0],       // Optional: control color transition points
              // tileMode: TileMode.clamp, // Optional: how to fill if gradient is smaller than container
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the date picker within the available title space
          mainAxisSize: MainAxisSize.min, // Try to keep the Row compact
          children: [
            TextButton(
              onPressed: () => _selectDate(context),
              style: TextButton.styleFrom(
                foregroundColor: gradientForegroundColor,
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding if needed
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {

              context.read<DashboardSaleService>().fetchDashboard(DateFormat('y-MM-dd').format(_selectedDate));
            },
          ),
          // You can add more IconButtons here if needed
          // IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Consumer<DashboardSaleService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                 service.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildChildren(context, service.dashboard),
              ),
            ),
          );
        },
      )/*,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<DashboardSaleService>(
          context,
          listen: false,
        ).fetchDashboard(),
        child: const Icon(Icons.refresh),
      ),*/
    );
  }

  List<Widget> _buildChildren(BuildContext context, Dashboard? dashboard) {
    List<Widget> children = [];
    if (dashboard == null) {
      return children; // Return empty list if dashboard is null
    }

    void addCard(String title, List<PairModel>? dataList, VoidCallback? onTap) {
      if (dataList != null && dataList.isNotEmpty) {
        children.add(_buildDataCard(context, title, dataList, onTap));
      }
    }

    addCard(
      'Ventes',
      dashboard.sales,
      () => Navigator.pushNamed(context, '/sales'),
    );
    addCard(
      'Montants Nets',
      dashboard.netAmounts,
      () => Navigator.pushNamed(context, '/sales'),
    );
    addCard('Types de Vente', dashboard.salesTypes, () => {});
    addCard('Modes de Paiement', dashboard.paymentModes, () => {});
    addCard('Commandes', dashboard.commandes, () => {});

    return children;
  }

  Widget _buildDataCard(
    BuildContext context,
    String title,
    List<PairModel> data,
    VoidCallback? onTap,
  ) {
    String firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';

    // Couleurs de la palette "Confiance et Sérénité" pour le CircleAvatar
    // Option 1: Utiliser la couleur primaire pour le texte et un conteneur primaire pour le fond
    final Color circleAvatarForegroundColor = Theme.of(
      context,
    ).colorScheme.primary; // Notre bleu #2A7AAE
    final Color baseColor = Theme.of(context).colorScheme.primaryContainer;
    final Color circleAvatarBackgroundColor = baseColor.withValues(
      alpha: 0.3,
    ); // RECOMMENDED

    return Card(
      elevation: 0.2,
      margin: const EdgeInsets.all(4.0),
      // Augmenté un peu la marge pour mieux respirer
      shape: RoundedRectangleBorder(
        // Coins arrondis pour un look plus doux
        borderRadius: BorderRadius.circular(8.0),
        // Si vous utilisez la bordure de la palette "Confiance et Sérénité"
        // side: BorderSide(color: Color(0xFFE9ECEF), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      // Utiliser la couleur de surface du thème pour le fond de la carte
      // color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // Aligner verticalement au centre
                children: [
                  CircleAvatar(
                    radius: 20, // Taille du cercle
                    backgroundColor: circleAvatarBackgroundColor,
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        fontSize: 18, // Taille de la lettre dans le cercle
                        fontWeight: FontWeight.bold,
                        color: circleAvatarForegroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Espace entre le cercle et le titre
                  Expanded(
                    // Pour que le titre gère bien les débordements
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // Utiliser une couleur de texte du thème pour le titre
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      // Gère les titres trop longs
                      maxLines:
                          2, // Permet au titre d'aller sur 2 lignes si besoin
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Augmenté un peu l'espacement
              // Séparateur subtil (optionnel, mais peut améliorer la structure visuelle)
              Divider(
                height: 1,
                color:
                    Theme.of(
                      context,
                    ).dividerTheme.color?.withValues(alpha: 0.5) ??
                    Colors.grey[300],
              ),
              const SizedBox(height: 12),
              ...data.map(
                (pair) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  // Augmenté le padding vertical
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        // Permet au 'code' de s'étendre et de gérer le débordement
                        flex: 2,
                        // Donne un peu plus d'espace au code si besoin
                        child: Text(
                          pair.code,
                          style: TextStyle(
                            fontSize: 15,
                            // Légèrement réduit pour différencier du titre
                            // Utiliser une couleur de texte du thème
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Petit espace entre code et valeur
                      Expanded(
                        // Permet à la 'value' de s'étendre
                        flex: 3,
                        child: Text(
                          pair.value,
                          // Assurez-vous que pair.value est une String
                          textAlign: TextAlign.end,
                          // Aligner la valeur à droite
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            // Semi-gras pour la valeur
                            // Utiliser une couleur de texte du thème, peut-être la couleur primaire pour la valeur
                            color: Theme.of(context)
                                .textTheme.bodyMedium?.color
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
