import 'package:warehouse_mobile/src/models/pair_model.dart';
import 'package:flutter/material.dart';

class SummaryData {
  final IconData icon;
  final List<PairModel> details;
  final Widget page;


  SummaryData(this.icon, this.details, this.page);
}
