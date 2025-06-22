
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/services/balance/balance_service.dart';
import 'package:warehouse_mobile/src/models/balance.dart';
import 'package:warehouse_mobile/src/models/card_data.dart';
import 'package:warehouse_mobile/src/models/card_name.dart';
import 'package:warehouse_mobile/src/utils/card_builder.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/custom_app_bar.dart';
import 'package:warehouse_mobile/src/utils/date_range_state.dart';
import 'package:warehouse_mobile/src/utils/filter_params_utils.dart';
import 'package:warehouse_mobile/src/utils/metter_group_builder.dart';
import 'package:warehouse_mobile/src/utils/service_state_wrapper.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({Key? key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {


  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateRangeState = Provider.of<DateRangeState>(context, listen: false);
      _fetchData(dateRangeState.selectedFromDate, dateRangeState.selectedToDate);
    });
  }

  Future<void> _fetchData(DateTime from,DateTime to) async {
    if (!mounted) return;
    final balanceService = Provider.of<BalanceService>(context, listen: false);
    final String fromDateString = Constant.datePattern.format(from);
    final String toDateString = Constant.datePattern.format(to);
    await balanceService.fetch(fromDateString, toDateString);
  }
  void _showDateRangePicker() {
    final dateRangeState = Provider.of<DateRangeState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Important for accommodating content and keyboard
      shape: Constant.roundedRectangleBorder,
      builder: (BuildContext bottomSheetContext) {
        return FilterParamsUtils(
          initialFromDate: dateRangeState.selectedFromDate,
          initialToDate: dateRangeState.selectedToDate,
          firstDate: Constant.firstDate,
          lastDate: Constant.lastDate,
          sheetTitleText: Constant.selectPeriodeText,
          onDateRangeSelected: (newFromDate, newToDate) {


          },
          onApplyAll: () {
            if (!mounted) return;
            final latestDates = Provider.of<DateRangeState>(context, listen: false);
            _fetchData(latestDates.selectedFromDate, latestDates.selectedToDate);
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final dateRangeState = context.watch<DateRangeState>();
    return Scaffold(
      appBar: CustomAppBar(
        fromDate: dateRangeState.selectedFromDate,
        toDate: dateRangeState.selectedToDate,
        onDateRangeTap: _showDateRangePicker,
        onRefreshTap: () => _fetchData(
          dateRangeState.selectedFromDate,
          dateRangeState.selectedToDate,
        ),
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
                      onRefresh:  () => _fetchData(
                        dateRangeState.selectedFromDate,
                        dateRangeState.selectedToDate,
                      ),
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

                );
              },
            ),
          ),
        ],
      ),


    );
  }
}
