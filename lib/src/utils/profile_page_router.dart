import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/main.dart';
import 'package:warehouse_mobile/src/data/auth/model/user.dart';
import 'package:warehouse_mobile/src/data/auth/servie/auth_service.dart';
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';
import 'package:warehouse_mobile/src/ui/auth/authenticate.dart';

class ProfilePageRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final apiClient = ApiClient();
    if ((apiClient.rememberMe && apiClient.user != null) ||
        authService.isAuthenticated) {
      User? user = apiClient.user;
      String? roleName = user?.roleName;
      print('User role: $roleName');
      return MyHomePage();
      // If the user is remembered, we can directly use the saved user
      // authService.setCurrentUser(apiClient.user!);
    } else {
      // If not remembered, we can clear the current user
      apiClient.clearCredentials();
      return Authenticate();
    }
    if (authService.isAuthenticated) {
      User? user = authService.currentUser;
      String? roleName = user?.roleName;
      print('User role: $roleName');
      return MyHomePage();
    }
    return Authenticate();
  }
}
