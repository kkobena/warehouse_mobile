import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:warehouse_mobile/src/data/auth/servie/auth_service.dart';
import 'package:warehouse_mobile/src/data/services/dahboard/dashboard_sale_service.dart';
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';
import 'package:warehouse_mobile/src/ui/auth/authenticate.dart';
import 'package:warehouse_mobile/src/ui/balance/widgets/balance_page.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_mobile/src/ui/home/dashboard_page.dart';
import 'package:warehouse_mobile/src/ui/setting/widgets/setting_page.dart';
import 'package:warehouse_mobile/src/ui/stock/widgets/stock_page.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/utils/app_drawer.dart';
import 'package:warehouse_mobile/src/utils/app_theme.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/profile_page_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await initializeDateFormatting('fr_FR', null);
  //TODO: faire un servie d'authentification pour recupérer l'url de l'api et les credentials et les stocker dans un box
  ApiClient().saveApiUrl('192.168.1.51:9080');

  //  ApiClient().saveCredentials("admin", "admin", true);
  final authService = AuthService();
  if (!authService.isAuthenticated && ApiClient().rememberMe) {
    await authService.autoLogin();
  }
  // If not authenticated, clear any previous user data

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => DashboardSaleService()),
        // Add other providers here if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.appName,
      theme: AppTheme.themeBleu,
      locale: const Locale('fr'),
      supportedLocales: const [
        Locale('fr', ''), // French, no country code
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // For iOS style widgets
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => ProfilePageRouter(), // Default route
        Authenticate.routeName: (context) => const Authenticate(),
        MyHomePage.routeName: (context) => const MyHomePage(),
        // Make sure MyHomePage has a routeName static const
        // Add other routes here
        // '/sales': (context) => SalesPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String routeName = '/home';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _pageTitles = [
    Constant.tableau, // Title for DashboardPage
    Constant.stock, // Title for StockPage
    Constant.balance, // Title for BalancePage
    Constant.recapitulatifCaisse, // Title for SettingPage
  ];

  int _currentIndex = 0;
  final List<Widget> _pages = [
    DashboardPage(),
    StockPage(),
    BalancePage(),
    SettingPage(),

    //  InventoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = context
        .watch<
          AuthService
        >(); // Use listen:false if only for one-time check or actions
    if (!authService.isAuthenticated) {
      // This block will execute after logout() and notifyListeners()
      // The `context` here is the fresh context of HomeContainerPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The `mounted` check here refers to the State of HomeContainerPage
        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil(Authenticate.routeName, (route) => false);
        }
      });
      // Return a loading indicator while the navigation takes place after the frame
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PopScope(
      canPop: authService.isAuthenticated,
      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop && !authService.isAuthenticated) {
          Navigator.pushReplacementNamed(context, Authenticate.routeName);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (newIndex) {
            setState(() {
              _currentIndex = newIndex;
              print('Index: $_currentIndex ');
            });
          },
          //  unselectedIconTheme: IconThemeData(color: Colors.grey),
          unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
          //   selectedItemColor: Colors.green[700],
          selectedItemColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          //  type: BottomNavigationBarType.shifting,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: Constant.tableau,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: Constant.stock,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sell),
              label: Constant.balance,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: Constant.recapitulatifCaisse,
            ),
          ],
        ),
        appBar: AppBar(
          title: Text(_pageTitles[_currentIndex]),
          leading: IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Ouvrir le menu',
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // Open the drawer
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Action pour les notifications
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                }

                await authService.logout();
              },
            ),
          ],
        ),
        body: IndexedStack(
          // Using IndexedStack to preserve state of pages
          index: _currentIndex,
          children: _pages,
        ),
        drawer: AppDrawer(),
      ),
    );
  }
}
