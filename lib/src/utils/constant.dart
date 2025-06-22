import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constant {
  static const String appName = 'Pharma Smart';
  static const String appVersion = 'Version 1.0.0';
  static const String profilAdmin = 'mobile_admin';
  static const String profilUser = 'mobile_user';
  static const String tableau = 'Accueil';
  static const String balance = 'Balance';
  static const String stock = 'Stock';
  static const String tva ='Rapport Tva';
  static const String recapitulatifCaisse = 'Caisse';
  static const String inventaire = 'Inventaire';
  static const String valider = 'VALIDER';
  static const String select = 'SELECTIONNER';
  static const String selectPeriodeText = 'Sélectionnez la période';
  static const String selectPeriodeOptions = 'Sélectionnez les paramètres';
  static const String annuler = 'ANNULER';
  static const String du = 'Du:';
  static const String au = 'Au:';
  static const String userResume = 'Total mobile';
  static const String resume = 'Total général';
  static const String onlyVenteText = 'Ventes uniquement';
  static DateTime fromDate = DateTime.now();
  static DateTime toDate = DateTime.now();
  static DateTime firstDate = DateTime(2024);
  static DateTime lastDate = DateTime.now();
  static  DateFormat datePattern =DateFormat('yyyy-MM-dd');
  static  RoundedRectangleBorder roundedRectangleBorder =const  RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const List<Color> metterGroupColors = [
    Color(0xFFFACC13),
    Color(0xFF6466F1),
    Color(0xFF39BDF8),
    Color(0xFFA855F7),
    Color(0xFF17B8A6),
    Color(0xFF22C45F),
    Color(0xFFF97316),
    Color(0xFFEAB30C),
    Color(0xFFEC4899),
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Violet
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFFEF4444), // Red
    Color(0xFF14B8A6), // Cyan
    Color(0xFF7C3AED),
    Color(0xFFA78BF9),
    // Teal
  ];
  static const pieChartColors = [
    Color(0xFF39BDF8),
    Color(0xFF6466F1),
    Color(0xFF17B8A6),
    Color(0xFFFACC13),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
  ];
}
