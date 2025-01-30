import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/constants/services/notification_service.dart';
import 'package:kokiku/constants/variables/prefs.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/firebase_options.dart';
import 'package:kokiku/locator.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/blocs/profile/profile_bloc.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/pages/inventory/add_edit_item_page.dart';
import 'package:kokiku/presentations/pages/inventory/inventory_page.dart';
import 'package:kokiku/presentations/pages/inventory/inventory_settings_page.dart';
import 'package:kokiku/presentations/pages/main_page.dart';
import 'package:kokiku/presentations/pages/onboarding/landing_page.dart';
import 'package:kokiku/presentations/pages/onboarding/onboarding_page.dart';
import 'package:kokiku/presentations/pages/profile/profile_page.dart';
import 'package:kokiku/presentations/pages/shopping_list/shopping_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Notification Service
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();

  // Set up dependency injection
  setupLocator();

  // Check first launch status
  bool isFirstLaunch = await checkIfFirstLaunch();

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
}

Future<bool> checkIfFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool(Prefs.isFirstLaunch) ?? true;
  if (isFirstLaunch) {
    await prefs.setBool(Prefs.isFirstLaunch, false);
  }
  return isFirstLaunch;
}

class MyApp extends StatefulWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  State<MyApp> createState() => _MyAppState();

  // Method to update the locale dynamically
  static void updateLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.updateLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default locale

  void updateLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => InventoryBloc()),
        // BlocProvider(create: (_) => ItemBloc()),
        BlocProvider(create: (_) => ShoppingListBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kokiku',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: _locale, // Use the updated locale
        localizationsDelegates: [
          LocalizationService.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('id', ''), // Indonesian
        ],
        initialRoute: _determineInitialRoute(),
        routes: {
          '/': (context) => MainPage(),
          '/inventory': (context) => InventoryPage(),
          // '/shopping': (context) => ShoppingListPage(),
          '/profile': (context) => ProfilePage(),
          '/onboarding': (context) => OnboardingPage(),
          '/landing': (context) => LandingPage(),
          '/inventorysettings': (context) => InventorySettingsPage(),
          '/addedit': (context) => AddEditItemPage(),
          // '/shoppinglist': (context) => ShoppingListPage(),
        },
      ),
    );
  }

  String _determineInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;
    if (widget.isFirstLaunch) return '/onboarding';
    return user != null ? '/' : '/landing';
  }
}

