import 'package:warehouse_mobile/src/models/feature_item.dart';
import 'package:flutter/material.dart';



class FeatureData{
  final String title;
  final IconData icon;
  final List<FeatureItem> details;
  FeatureData(this.title,this.icon,this.details);

}