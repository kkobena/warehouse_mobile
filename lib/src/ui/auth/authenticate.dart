import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/main.dart';
import 'package:warehouse_mobile/src/data/auth/servie/auth_service.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';

import '../../data/services/utils/api_client.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  static const String routeName = '/auth';

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _apiUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isApiUrlEditable = true;

  @override
  void initState() {
    super.initState();
    // Initialize _apiUrlController with the current API URL from ApiClient
    _apiUrlController.text = apiClient.appIp ?? '';
    _isApiUrlEditable =
        apiClient.appIp == null || apiClient.appIp!.trim().isEmpty;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authService = context.read<AuthService>();
      await authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _apiUrlController.text.trim(),
      );

      if (authService.isAuthenticated && mounted) {

        Navigator.of(context).pushReplacementNamed(
          MyHomePage.routeName,
        );
      } else if (mounted) {
        // Show error message from authService.errorMessage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authService.errorMessage.isNotEmpty
                  ? authService.errorMessage
                  : 'Échec de la connexion inattendu.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
              /*  Image.asset(
                  'assets/images/appstore.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),*/
                Icon(
                  Icons.add_circle_outline_rounded, // Or your app logo
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  Constant.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _apiUrlController,
                        enabled: _isApiUrlEditable,
                        decoration: InputDecoration(
                          labelText: 'Ip et port du service',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer l\'URL du service.';
                          }
                          final trimmedValue = value.trim();

                          // Regex for IP address with a required port
                          final isIpWithPort = RegExp(
                            r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?):\d+$',
                          ).hasMatch(trimmedValue);
                          if (!isIpWithPort) {
                            return '(ex: 192.168.1.1:8080)';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (!_isApiUrlEditable)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isApiUrlEditable = true;
                          });
                        },
                        tooltip: 'Modifier l\'URL du service',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Username/Email Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre nom d\'utilisateur.';
                    }
                    // Optional: Add more specific email validation if needed
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe.';
                    }
                    // Optional: Add password strength validation
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login Button
                authService.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _performLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        child: const Text(
                          'SE CONNECTER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // TextButton(
                //   onPressed: () {
                //     // TODO: Navigate to Sign Up page
                //   },
                //   child: Text('Pas de compte ? S\'inscrire'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
