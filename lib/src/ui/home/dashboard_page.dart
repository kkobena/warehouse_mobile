import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/dahboard/dashboard_sale_service.dart';
import 'package:warehouse_mobile/src/models/dashboard.dart';
import 'package:warehouse_mobile/src/models/list_item.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_mobile/src/utils/card_builder.dart';
import 'package:warehouse_mobile/src/utils/metter_group_builder.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    Key? key,
  }) ;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardSaleService>().fetchDashboard(
        DateFormat('y-MM-dd').format(_selectedDate),
      );
    });
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
      (hslPrimary.lightness + lightnessIncrease).clamp(0.0, 1.0),
    );
    final Color lighterPrimaryColor = hslLighterPrimary.toColor();

    final Color gradientStart = primaryColor;
    final Color gradientEnd = lighterPrimaryColor;
    Color gradientForegroundColor = Theme.of(context).colorScheme.onPrimary;
    const Color gradientForeground = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        foregroundColor: gradientForeground,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft, // Gradient start position
              end: Alignment.bottomRight, // Gradient end position

            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // Center the date picker within the available title space
          mainAxisSize: MainAxisSize.min,
          // Try to keep the Row compact
          children: [
            TextButton(
              onPressed: () => _selectDate(context),
              style: TextButton.styleFrom(
                foregroundColor: gradientForegroundColor,
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ), // Adjust padding if needed
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              context.read<DashboardSaleService>().fetchDashboard(
                DateFormat('y-MM-dd').format(_selectedDate),
              );
            },
          ),
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
      ) /*,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<DashboardSaleService>(
          context,
          listen: false,
        ).fetchDashboard(),
        child: const Icon(Icons.refresh),
      ),*/,
    );
  }

  List<Widget> _buildChildren(BuildContext context, Dashboard? dashboard) {
    List<Widget> children = [];
    if (dashboard == null) {
      return children; // Return empty list if dashboard is null
    }

    void addMetterGroup(String title, List<ListItem>? dataList, VoidCallback? onTap) {
      if (dataList != null && dataList.isNotEmpty) {
        children.add(
          buildMetterGroup(
            context: context,
            title: title,
            data: dataList,
            onTap: onTap,
          ),
        );
      }
    }



    void addCard(String title, List<ListItem>? dataList, VoidCallback? onTap) {
      if (dataList != null && dataList.isNotEmpty) {
        children.add(
          buildDataCard(
            context: context,
            title: title,
            data: dataList,
            onTap: onTap,
          ),
        );
      }
    }

    addCard(
      'Ventes',
      dashboard.sales,
      () => {},
      //  () => Navigator.pushNamed(context, '/sales'),
    );
    addCard(
      'Montants Nets',
      dashboard.netAmounts,
      () => Navigator.pushNamed(context, '/sales'),
    );
    addCard('Types de Vente', dashboard.salesTypes, () => {});
    addMetterGroup('Modes de Paiement', dashboard.paymentModes, () => {});
    addCard('Commandes', dashboard.commandes, () => {});

    return children;
  }
}
