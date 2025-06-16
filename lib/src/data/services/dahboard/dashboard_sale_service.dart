import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_mobile/src/data/services/dahboard/model/dashboard.dart';
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';

class DashboardSaleService extends ChangeNotifier {
  Dashboard? _dashboard;
  bool _isLoading = false;
  String _errorMessage = '';

  Dashboard? get dashboard => _dashboard;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;


  Future<void> fetchDashboard(String? fromDate) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final apiClient = ApiClient();
      final String apiUrl = '${apiClient.apiUrl}/mobile/dashboard/data';
      final Map<String, String> queryParameters = {};
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParameters['fromDate'] = fromDate;
      }

      final uri = Uri.parse(apiUrl).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiClient.basicAuth,

        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          _dashboard = null;
          _errorMessage = 'Aucun résultat trouvé.';
        } else {

          try {
            _dashboard = Dashboard.fromJson(json.decode(response.body));
            _errorMessage = ''; // Clear error on success
          } catch (e) {
            _dashboard = null;
            _errorMessage = 'Erreur lors de l\'analyse des données reçues.';

          }
        }
      } else {

        _dashboard = null;
        if (response.statusCode == 401 || response.statusCode == 403) {
          _errorMessage = 'Non autorisé. Veuillez vérifier vos identifiants.';
        } else if (response.statusCode >= 500) {
          _errorMessage = 'Erreur du serveur (Code: ${response.statusCode}). Veuillez réessayer plus tard.';
        } else {
          _errorMessage = 'Erreur lors du chargement des données (Code: ${response.statusCode}).';
        }

      }
    }  finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
