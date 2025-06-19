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
import 'package:warehouse_mobile/src/ui/inventory/widgets/inventory_page.dart';
import 'package:warehouse_mobile/src/ui/setting/widgets/setting_page.dart';
import 'package:warehouse_mobile/src/ui/stock/widgets/stock_page.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_mobile/src/utils/app_drawer.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';
import 'package:warehouse_mobile/src/utils/profile_page_router.dart';
import 'package:warehouse_mobile/src/utils/theme_profiver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await initializeDateFormatting('fr_FR', null);

  final authService = AuthService();
  if (!authService.isAuthenticated && ApiClient().rememberMe) {
    await authService.autoLogin();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => DashboardSaleService()),
        ChangeNotifierProvider(create: (_) => ThemeProfiver()),
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
    final themeProvider = Provider.of<ThemeProfiver>(context);
    return MaterialApp(
      title: Constant.appName,
      theme:themeProvider.currentTheme ,
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
  List<String> _pageTitles = [
    Constant.tableau, // Title for DashboardPage
    Constant.stock, // Title for StockPage
    Constant.balance, // Title for BalancePage
    Constant.recapitulatifCaisse, // Title for SettingPage
  ];
  List<Widget> _pages = [];

  List<BottomNavigationBarItem> _navBarItems = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // You can initialize any data or state here if needed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is a good place to set up role-dependent UI elements
    // because it's called after initState and when dependencies change (like Provider).
    _setupRoleBasedUI();
  }

  void _setupRoleBasedUI() {
    final authService = Provider.of<AuthService>(
      context,
      listen: false,
    ); // listen: false is okay here
    final String? role = authService.currentUserRole;

    // Default common pages (can be overridden by role-specific bodies)
    // For now, let's keep the _pages simple and use a role-specific body.
    // The BottomNav items could also change per role.

    // Example: Tailor BottomNavigationBar items and pages by role
    if (role == Constant.profilAdmin) {
      _pages = [DashboardPage(), StockPage(), BalancePage(), SettingPage()];
      _navBarItems = const [
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
      ];
    } else if (role == Constant.profilUser) {
      _pageTitles = [Constant.inventaire];
      _pages = [InventoryPage()];
      _navBarItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: Constant.stock,
        ),
      ];
    }

    // Ensure _currentIndex is valid if the number of pages changed.
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
    // Trigger a rebuild if called from didChangeDependencies and state actually changed.
    // No explicit setState needed if this is the first time it's built or
    // if Provider above triggers a rebuild. If you call this method at other times,
    // you might need setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authService = context
        .watch<
          AuthService
        >(); // Use listen:false if only for one-time check or actions
    if (!authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil(Authenticate.routeName, (route) => false);
        }
      });

      return const PopScope(
        canPop: false,
        onPopInvokedWithResult: null,
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_pages.isEmpty && authService.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _setupRoleBasedUI(); // Try to set up again
          });
        }
      });
      if (_pages.isEmpty) {
        // If still empty after attempting setup
        return const Scaffold(
          body: Center(child: Text("Chargement de la configuration...")),
        );
      }
    }
    final String? role = authService.currentUserRole;
    return PopScope(
      canPop: authService.isAuthenticated,
      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop && !authService.isAuthenticated) {
          Navigator.pushReplacementNamed(context, Authenticate.routeName);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: _navBarItems.isNotEmpty && _navBarItems.length > 1
            ? BottomNavigationBar(
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
                items: _navBarItems,
              )
            : null,
        appBar: AppBar(
          title: _pages.isNotEmpty && _pages.length > 1
              ? Text(_pageTitles[_currentIndex])
              : Text(_pageTitles[0]),
          leading: role == Constant.profilAdmin
              ? IconButton(
                  icon: Icon(Icons.menu),
                  tooltip: 'Ouvrir le menu',
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer(); // Open the drawer
                  },
                )
              : null,
          actions: role == Constant.profilAdmin
              ? [
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
                ]
              : [
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
          children: _pages.isNotEmpty
              ? _pages
              : [const Center(child: Text("Loading..."))],

          //  children: _pages,
        ),
        drawer: AppDrawer(),
      ),
    );
  }
}
