import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';
import 'package:warehouse_mobile/src/models/balance.dart';

class BalanceService extends ChangeNotifier {
  Balance? _balance;
  bool _isLoading = false;
  String _errorMessage = '';

  Balance? get balance => _balance;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  Future<void> fetchDashboard(String fromDate, String toDate) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final apiClient = ApiClient();
      final String apiUrl = '${apiClient.apiUrl}/mobile/balance';
      final Map<String, String> queryParameters = {};
      if (fromDate.isNotEmpty) {
        queryParameters['fromDate'] = fromDate;
      }
      if (toDate.isNotEmpty) {
        queryParameters['toDate'] = toDate;
      }

      final uri = Uri.parse(apiUrl).replace(queryParameters: queryParameters);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': apiClient.basicAuth,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          _balance = null;
          _errorMessage = 'Aucun résultat trouvé.';
        } else {
          try {
            _balance = Balance.fromJson(json.decode(response.body));
            _errorMessage = ''; // Clear error on success
          } catch (e) {
            _balance = null;
            _errorMessage = 'Erreur lors de l\'analyse des données reçues.';
          }
        }
      } else {
        _balance = null;
        if (response.statusCode == 401 || response.statusCode == 403) {
          _errorMessage = 'Non autorisé. Veuillez vérifier vos identifiants.';
        } else if (response.statusCode >= 500) {
          _errorMessage =
              'Erreur du serveur (Code: ${response.statusCode}). Veuillez réessayer plus tard.';
        } else {
          _errorMessage =
              'Erreur lors du chargement des données (Code: ${response.statusCode}).';
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
