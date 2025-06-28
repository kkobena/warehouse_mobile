import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';

class SharedService {
  final ApiClient _apiClient;

  SharedService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<T?> fetchData<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic> json) parserFromJson,
    required ValueChanged<bool> setLoading,
    required ValueChanged<String> setError,
    required VoidCallback notifyListenersCallback,
  }) async {
    setLoading(true);
    setError('');
    notifyListenersCallback();

    try {
      final String apiUrl = '${_apiClient.apiUrl}$endpoint';
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters?.isNotEmpty == true
            ? queryParameters
            : null,
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': _apiClient.basicAuth,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          setError('Aucun résultat trouvé.'); // Still specific for "no data"
          return null;
        }
        final decodedBody = json.decode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          return parserFromJson(decodedBody);
        } else {
          setError('Format de données inattendu.');
          if (kDebugMode) {
            print(
              "SharedService: Expected Map<String, dynamic> but got ${decodedBody.runtimeType} for $endpoint",
            );
          }
          return null;
        }
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          setError('Accès non autorisé.');
        } else {
          setError(
            'Erreur de communication avec le serveur (Code: ${response.statusCode}).',
          );
        }
        if (kDebugMode) {
          print(
            "SharedService HTTP Error ${response.statusCode} for $endpoint: ${response.body}",
          );
        }
        return null;
      }
    } catch (e) {
      setError('Une erreur inattendue s\'est produite. Veuillez réessayer.');
      if (kDebugMode) {
        print('SharedService Generic Error for $endpoint: $e');
      }
      return null;
    } finally {
      setLoading(false);
      notifyListenersCallback();
    }
  }

  Future<List<T>?> fetchListData<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic> json) itemParserFromJson,
    required ValueChanged<bool> setLoading,
    required ValueChanged<String> setError,
    required VoidCallback notifyListenersCallback,
  }) async {
    setLoading(true);
    setError(''); // Clear previous errors
    notifyListenersCallback(); // Notify loading started, error cleared

    try {
      final String apiUrl = '${_apiClient.apiUrl}$endpoint';
      final Uri uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters?.isEmpty ?? true
            ? null
            : queryParameters,
      );

      final http.Response response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': _apiClient.basicAuth,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          setError('');
          return [];
        } else {
          final decodedBody = json.decode(response.body);
          if (decodedBody is List) {
            if (decodedBody.isEmpty) {
              return [];
            }

            final List<T> results = decodedBody.map((itemJson) {
              if (itemJson is Map<String, dynamic>) {
                return itemParserFromJson(itemJson);
              } else {
                setError(
                  'Format de données inattendu reçu du serveur. Attendu une liste.',
                );

                throw FormatException(
                  'Unexpected item format in list. Expected Map<String, dynamic>, got ${itemJson.runtimeType}',
                  itemJson,
                );
              }
            }).toList();
            return results;
          } else {
            // The entire response body was not a List as expected
            setError(
              'Format de données inattendu reçu du serveur. Attendu une liste.',
            );
            if (kDebugMode) {
              print(
                "SharedService: Expected List for $endpoint but got ${decodedBody.runtimeType}",
              );
            }
            return null; // Or return an empty list: []
          }
        }
      } else {
        // Handle HTTP error codes
        if (response.statusCode == 401 || response.statusCode == 403) {
          setError('Non autorisé. Veuillez vérifier vos identifiants.');
        } else if (response.statusCode == 404) {
          setError('Ressource non trouvée.'); // Specific 404
          return []; // Often, a 404 for a list endpoint might mean an empty list or "not found"
        } else if (response.statusCode >= 500) {
          setError('Erreur du serveur. Veuillez réessayer plus tard.');
        } else {
          setError(
            'Erreur lors du chargement des données (Code: ${response.statusCode}).',
          );
        }
        if (kDebugMode) {
          print(
            "SharedService HTTP Error ${response.statusCode} for $endpoint: ${response.body}",
          );
        }
        return null;
      }
    } catch (e) {
      setError('Une erreur inattendue s\'est produite: ${e.toString()}');
      if (kDebugMode) {
        print('SharedService Unexpected error for $endpoint: $e');
      }
      return null;
    } finally {
      setLoading(false);
      notifyListenersCallback();
    }
  }
}
