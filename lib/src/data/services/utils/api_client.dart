import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:warehouse_mobile/src/data/auth/model/user.dart';
import 'package:warehouse_mobile/src/utils/theme_provider.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  final Box _box = Hive.box('settings');

  Future<void> saveApiUrl(String apiUrl) async {
    await _box.put('apiUrl', 'http://$apiUrl/java-client');
    await _box.put('auth', 'http://$apiUrl/api-user-account');
    await _box.put('appIp', apiUrl);
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

  String? get appIp => _box.get('appIp');

  String? get _username => _box.get('username');

  String? get _password => _box.get('password');

  String? get username => _username;

  String? get password => _password;

  bool get rememberMe => _box.get('rememberMe', defaultValue: false);

  AppThemes get theme => fromString(_box.get('theme', defaultValue: 'bleu'));

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

  Future<void> updateTheme(AppThemes th) async {

    await _box.put('theme', th.name);
  }

  AppThemes fromString(String value) {

    return AppThemes.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AppThemes.bleu, // or return null if nullable
    );
  }
}
