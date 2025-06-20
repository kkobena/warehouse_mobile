
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/balance/balance_service.dart';
import 'package:warehouse_mobile/src/models/balance.dart';
import 'package:warehouse_mobile/src/models/card_data.dart';
import 'package:warehouse_mobile/src/models/card_name.dart';
import 'package:warehouse_mobile/src/utils/card_builder.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/custom_app_bar.dart';
import 'package:warehouse_mobile/src/utils/date_range_picker.dart';
import 'package:warehouse_mobile/src/utils/metter_group_builder.dart';
import 'package:warehouse_mobile/src/utils/service_state_wrapper.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({Key? key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    /*   WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BalanceService>().fetch(
        DateFormat('yyyy-MM-dd').format(_fromDate),
        DateFormat('yyyy-MM-dd').format(_toDate),
      );
    });*/
  }

  Future<void> _fetchBalanceData() async {
    if (!mounted) return;
    final balanceService = Provider.of<BalanceService>(context, listen: false);
    final String fromDateString = DateFormat('yyyy-MM-dd').format(_fromDate);
    final String toDateString = DateFormat('yyyy-MM-dd').format(_toDate);
    await balanceService.fetch(fromDateString, toDateString);
  }

  void _showDateRangePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Important for accommodating content and keyboard
      shape: const RoundedRectangleBorder(
        // Optional: for rounded top corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return DateRangePicker(
          initialFromDate: _fromDate,
          initialToDate: _toDate,
          firstDate: Constant.firstDate,
          lastDate: Constant.lastDate,
          onDateRangeSelected: (newFromDate, newToDate) {
            setState(() {
              _fromDate = newFromDate;
              _toDate = newToDate;
            });
            // After setting new dates, refetch the balance data
            _fetchBalanceData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        fromDate: _fromDate,
        toDate: _toDate,
        onDateRangeTap: _showDateRangePicker,
        onRefreshTap: _fetchBalanceData,
      ),

      body: Column(
        children: [
          Expanded(
            child: Consumer<BalanceService>(
              builder: (context, balanceService, child) {
                return ServiceStateWrapper<BalanceService, Balance>(
                  service: balanceService,
                  data: balanceService.balance, // Pass the actual data object
                  successBuilder: (BuildContext context, Balance balanceData) {
                    return RefreshIndicator(
                      onRefresh: _fetchBalanceData,
                      // Call the method that uses current dates
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: balanceData.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CardData cardDetails = balanceData.items[index];
                          switch (CardName.fromString(cardDetails.title)) {
                            case CardName.resume:
                              return buildDataCard(
                                context: context,
                                title: CardName.fromString(
                                  cardDetails.title,
                                ).toString(),
                                data: cardDetails.items,
                                onTap: () {},
                              );
                            case CardName.typeVente:
                            case CardName.modePaiement:
                            case CardName.typeMvt:
                              return buildMetterGroup(
                                context: context,
                                title: CardName.fromString(
                                  cardDetails.title,
                                ).toString(),
                                data: cardDetails.items,
                                onTap: () {},
                              );
                          }
                        },
                      ),
                    );
                  },
                  // Optional: Provide custom loading, error, or empty widgets
                  // loadingWidget: MyCustomLoadingSpinner(),
                  // emptyDataWidget: MyCustomEmptyStateIllustration(),
                  // errorBuilder: (context, errorMessage) => MyCustomErrorWidget(message: errorMessage),
                );
              },
            ),
          ),
        ],
      ),

      /*,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<DashboardSaleService>(
          context,
          listen: false,
        ).fetchDashboard(),
        child: const Icon(Icons.refresh),
      ),*/
    );
  }
}
