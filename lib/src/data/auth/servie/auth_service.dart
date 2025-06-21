import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:warehouse_mobile/src/data/auth/model/user.dart';
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  User? _currentUser;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _isAuthenticated;

  String? get currentUserRole => _currentUser?.roleName;

  Future<void> login(String usernameOrEmail, String password,String? apiurl) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (apiurl != null) {
        await ApiClient().saveApiUrl(apiurl);
      }
      final Uri loginUri = Uri.parse('${ApiClient().authUrl}'); // Ensure ApiClient().authUrl is correctly set

      final response = await http.post(
        loginUri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'username': usernameOrEmail,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5),
          onTimeout: () {

            throw SocketException(
                "La connexion au serveur a expiré. Veuillez vérifier votre connexion internet et réessayer.");
          });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = User.fromJson(responseData);

        if (_currentUser != null) {
          if (checkUserRole()) {
            await ApiClient().saveUser(
              _currentUser!,
              password,
              true,
            );
            _isAuthenticated = true;
            _errorMessage = ''; // Clear previous errors
          } else {
            _isAuthenticated = false;
            _errorMessage = 'L\'utilisateur n\'a pas de rôle défini.';
          }
        } else {
          _isAuthenticated = false;
          _errorMessage = 'Échec de la connexion. Utilisateur introuvable .';
        }
      } else {

        _isAuthenticated = false;
        try {
          final errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? 'Échec de la connexion';
        } catch (e) {
          _errorMessage = 'Échec de la connexion';
        }
      }
    } on SocketException {
      _isAuthenticated = false;
      _errorMessage = 'Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet et réessayer.';

    } on http.ClientException {

      _isAuthenticated = false;
      _errorMessage = 'Erreur de connexion au serveur: Veuillez vérifier votre connexion et l\'URL du serveur.';

    } catch (e) {

      _isAuthenticated = false;
      _errorMessage = 'Une erreur inattendue s\'est produite';

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = '';
    await ApiClient().clearCredentials();
    _isAuthenticated = false;
    notifyListeners();
  }

  bool checkUserRole() {
    final String? roleName = _currentUser?.roleName; // Get roleName safely
    return roleName != null && roleName.isNotEmpty;
  }

  Future<void> autoLogin() async {
    await login(ApiClient().username ?? '', ApiClient().password ?? '', null);
  }
}
