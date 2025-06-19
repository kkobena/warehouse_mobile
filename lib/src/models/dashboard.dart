import 'package:warehouse_mobile/src/models/pair_model.dart';

class Dashboard {
  List<PairModel>? sales;
  List<PairModel>? netAmounts;
  List<PairModel>? salesTypes;
  List<PairModel>? counts;
  List<PairModel>? paymentModes;
  List<PairModel>? commandes;

  Dashboard({
    this.sales,
    this.netAmounts,
    this.salesTypes,
    this.counts,
    this.paymentModes,
    this.commandes,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      sales: (json['sales'] as List<dynamic>?)
          ?.map((e) => PairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      netAmounts: (json['netAmounts'] as List<dynamic>?)
          ?.map((e) => PairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      salesTypes: (json['salesTypes'] as List<dynamic>?)
          ?.map((e) => PairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      counts: (json['counts'] as List<dynamic>?)
          ?.map((e) => PairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentModes: (json['paymentModes'] as List<dynamic>?)
          ?.map((e) => PairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      commandes: (json['commandes'] as List<dynamic>?)
          ?.map((e) => PairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sales': sales?.map((e) => e.toJson()).toList(),
    'netAmounts': netAmounts?.map((e) => e.toJson()).toList(),
    'salesTypes': salesTypes?.map((e) => e.toJson()).toList(),
    'counts': counts?.map((e) => e.toJson()).toList(),
    'paymentModes': paymentModes?.map((e) => e.toJson()).toList(),
    'commandes': commandes?.map((e) => e.toJson()).toList(),
  };
}
