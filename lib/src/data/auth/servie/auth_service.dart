import 'dart:convert';

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

  Future<void> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final Uri loginUri = Uri.parse('${ApiClient().authUrl}');

      final response = await http.post(
        loginUri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'username': usernameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Assuming the response directly contains user data and potentially a token
        // Adjust parsing based on your API's actual response structure
        _currentUser = User.fromJson(responseData);

        if (_currentUser != null) {
          if (checkUserRole()) {
            await ApiClient().saveUser(
              _currentUser!,
              password,
              true, // Assuming you want to remember the user
            );
            _isLoading = false;
            _isAuthenticated = true;
          } else {
            _errorMessage = 'L\'utilisateur n\'a pas de rôle défini.';
            _isLoading = false;
            _isAuthenticated = false;
          }
          notifyListeners();
        } else {
          _errorMessage =
              'Echec de la connexion. L\'utilisateur est introuvable.';
          _isLoading = false;
          _isAuthenticated = false;
          notifyListeners();
        }
      } else {
        // Attempt to parse error message from response
        try {
          final errorData = json.decode(response.body);
          _errorMessage =
              errorData['message'] ??
              'Échec de la connexion. Code: ${response.statusCode}';
        } catch (e) {
          _errorMessage =
              'Échec de la connexion. Code: ${response.statusCode}. Réponse invalide.';
        }
        _isLoading = false;
        _isAuthenticated = false;
        notifyListeners();
      }
    } catch (e) {
      print('Login error: $e');
      _errorMessage = 'Une erreur s\'est produite: ${e.toString()}';
      _isLoading = false;
      _isAuthenticated = false;
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

      await login(
        ApiClient().username ?? '',
        ApiClient().password ?? '',
      );

  }
}
