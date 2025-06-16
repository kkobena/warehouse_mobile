import 'dart:convert';


import 'package:hive/hive.dart';

import 'package:warehouse_mobile/src/data/auth/model/user.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  // http://192.168.1.51:9080/java-client
  ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }


  final Box _box = Hive.box('settings');

  Future<void> saveApiUrl(String apiUrl) async {
    await _box.put('apiUrl', 'http://$apiUrl/java-client');
    await _box.put('auth', 'http://$apiUrl/api-user-account');
  }

  Future<void> saveCredentials(
    String username,
    String password,
    bool rememberMe,
  ) async {
    await _box.put('username', username);
    await _box.put('password', password);
    await _box.put('rememberMe', rememberMe);
  }

  Future<void> saveUser(User user, String password, bool rememberMe) async {
    await _box.put('username', user.login);
    await _box.put('password', password);
    await _box.put('rememberMe', rememberMe);
    await _box.put('user', user.toJson());
  }

  String? get apiUrl => _box.get('apiUrl');
  String? get authUrl => _box.get('auth');

  String? get _username => _box.get('username');

  String? get _password => _box.get('password');
  String? get username => _username;
  String? get password => _password;
  bool get rememberMe => _box.get('rememberMe', defaultValue: false);
  User? get user {
    final userJson = _box.get('user');
    if (userJson != null) {
      return User.fromJson(Map<String, dynamic>.from(userJson));
    }
    return null;
  }



  String get basicAuth {
    final username = _username ?? '';
    final password = _password ?? '';
    return 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  }

  Future<void> clearCredentials() async {
    await _box.delete('username');
    await _box.delete('password');
    await _box.delete('rememberMe');
    await _box.delete('user');
  }
}
