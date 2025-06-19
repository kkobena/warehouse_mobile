import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/data/auth/model/user.dart';
import 'package:warehouse_mobile/src/data/auth/servie/auth_service.dart';
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';
import 'package:warehouse_mobile/src/ui/auth/authenticate.dart';
import 'package:warehouse_mobile/src/utils/theme_profiver.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme data and auth service
    final ThemeData theme = Theme.of(context);
    final authService = context.watch<AuthService>();

    final themeProvider=Provider.of<ThemeProfiver>(context);
    final apiClient = ApiClient();
   // final User? currentUser = apiClient.user;
    final User? currentUser = authService.currentUser;
    // Define colors from theme for consistency (could also be passed as parameters if needed)
    final Color drawerHeaderColor = theme.colorScheme.primary;
    final Color drawerHeaderTextColor = theme.colorScheme.onPrimary;
    final Color drawerIconColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.7,
    );
    final Color drawerTextColor = theme.colorScheme.onSurface;

    final String username =
        currentUser?.abbrName ?? 'Menu';

   // final IconData headerIcon = Icons.add_circle_outline_rounded;
    final IconData headerIcon =  Icons.add_circle_outline_rounded; // Example dynamic icon
    final String themeSwitchLabel = themeProvider.currentThemeKey == AppThemes.bleu
        ? 'Mode Sombre (Bleu)'
        : 'Mode Clair (Vert)';


    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: drawerHeaderColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(headerIcon, size: 48, color: drawerHeaderTextColor),
                const SizedBox(height: 12),
                Text(
                  username, // Display username or app name
                  style: TextStyle(
                    color: drawerHeaderTextColor,
                    fontSize: 20,

                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long names
                ),


              ],
            ),
          ),
          SwitchListTile(
            title: Text(
              themeSwitchLabel, // Dynamic label
              style: TextStyle(color: drawerTextColor),
            ),
            value: themeProvider.currentThemeKey == AppThemes.bleu, // Switch is "on" if current theme is Bleu
            onChanged: (bool value) {
              // If value is true, switch to Bleu (dark/alternative), otherwise switch to Vert (light/default)
              themeProvider.setTheme(value ? AppThemes.bleu : AppThemes.vert);
              // Or, if you added the toggleTheme method:
            // themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.currentThemeKey == AppThemes.bleu ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: drawerIconColor,
            ),
            activeColor: theme.colorScheme.primary, // Color of the switch when it's ON
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: drawerIconColor),
            title: Text('À Propos', style: TextStyle(color: drawerTextColor)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // TODO: Implement About Page navigation or Dialog
              print('À Propos cliqué');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('À Propos: Bientôt disponible!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.mail_outline, color: drawerIconColor),
            title: Text(
              'Nous Contacter',
              style: TextStyle(color: drawerTextColor),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // TODO: Implement Contact functionality (e.g., mailto link, contact form)
              print('Nous Contacter cliqué');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nous Contacter: Bientôt disponible!'),
                ),
              );
            },
          ),

          const Divider(), // Use theme's divider color by default, or customize

            ListTile(
              leading: Icon(Icons.logout, color: drawerIconColor),
              title: Text(
                'Déconnexion',
                style: TextStyle(color: drawerTextColor),
              ),
              onTap: () async {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }
                await authService.logout();


              },
            )

        ],
      ),
    );
  }
}
