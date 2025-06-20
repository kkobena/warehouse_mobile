import 'dart:convert';
import 'dart:io'; //

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
    required VoidCallback notifyListenersCallback
  }) async {
    setLoading(true);
    setError(''); // Clear previous errors
    notifyListenersCallback(); // Notify loading started, error cleared

    try {
      final String apiUrl = '${_apiClient.apiUrl}$endpoint';
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters!.isEmpty ? null : queryParameters,
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
          setError('Aucun résultat trouvé.');
          return null;
        } else {
          try {

            final decodedBody = json.decode(response.body);
            if (decodedBody is Map<String, dynamic>) {
              return parserFromJson(decodedBody);
            } else {

              setError(
                'Format de données inattendu reçu du serveur .',
              );
              if (kDebugMode) {
                print(
                  "SharedService: Expected Map<String, dynamic> but got ${decodedBody.runtimeType}",
                );
              }
              return null;
            }
          } on FormatException catch (e) {
            // More specific catch for json.decode errors
            setError(
              'Erreur lors de l\'analyse des données reçues.',
            );
            if (kDebugMode) {
              print(
                "SharedService JSON Parsing Error (FormatException) for $endpoint: $e",
              );
            }
            return null;
          } catch (e) {
            // Catch other errors during parsing
            setError('Erreur lors de l\'analyse des données reçues.');
            if (kDebugMode) {
              print("SharedService Parsing Error for $endpoint: $e");
            }
            return null;
          }
        }
      } else {
        // Handle HTTP error codes
        if (response.statusCode == 401 || response.statusCode == 403) {
          setError('Non autorisé. Veuillez vérifier vos identifiants.');
        } else if (response.statusCode >= 500) {
          setError(
            'Erreur du serveur. Veuillez réessayer plus tard.',
          );
        } else {
          setError(
            'Erreur lors du chargement des données.',
          );
        }
        // Log the response body for non-200 for debugging if helpful
        if (kDebugMode) {
          print(
            "SharedService HTTP Error ${response.statusCode} for $endpoint: ${response.body}",
          );
        }
        return null;
      }
    } on SocketException catch (e) {
      setError(
        'Impossible de se connecter au serveur. Vérifiez votre connexion internet',
      );
      if (kDebugMode) {
        print('SharedService Network/Socket Error for $endpoint: $e');
      }
      return null;
    } on http.ClientException catch (e) {
      // Handles timeouts from ApiClient.request if it throws ClientException
      setError('Erreur de connexion au serveur');
      if (kDebugMode) {
        print('SharedService ClientException for $endpoint: $e');
      }
      return null;
    } catch (e) {
      // Catch-all for any other unexpected errors
      setError('Une erreur inattendue s\'est produite');
      if (kDebugMode) {
        print('SharedService Unexpected error for $endpoint: $e');
      }
      return null;
    } finally {
      setLoading(false);
      notifyListenersCallback(); // Notify loading finished
    }
  }
}
