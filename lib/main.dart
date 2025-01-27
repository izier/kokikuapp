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
import 'package:kokiku/presentations/blocs/item/item_bloc.dart';
import 'package:kokiku/presentations/blocs/profile/profile_bloc.dart';
import 'package:kokiku/presentations/pages/inventory/add_edit_item_page.dart';
import 'package:kokiku/presentations/pages/inventory/inventory_page.dart';
import 'package:kokiku/presentations/pages/main_page.dart';
import 'package:kokiku/presentations/pages/onboarding/landing_page.dart';
import 'package:kokiku/presentations/pages/onboarding/onboarding_page.dart';
import 'package:kokiku/presentations/pages/profile/profile_page.dart';
import 'package:kokiku/presentations/pages/shopping_list/shopping_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkIfFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  // If it's the first launch, set 'isFirstLaunch' to false
  if (isFirstLaunch) {
    await prefs.setBool(Prefs.isFirstLaunch, false);
  }

  return isFirstLaunch;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool(Prefs.isFirstLaunch) ?? true;

  if (isFirstLaunch) {
    await prefs.setBool(Prefs.isFirstLaunch, false);
  }

  setupLocator();
  runApp(MyApp(isFirstLaunch: isFirstLaunch));
}

class MyApp extends StatefulWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  State<MyApp> createState() => _MyAppState();

  // Method to update the locale
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setState(() {
      state._locale = newLocale;
    });
  }
}

class _MyAppState extends State<MyApp> {
  // Check if the user is signed in
  User? user = FirebaseAuth.instance.currentUser;
  Locale _locale = Locale('en'); // Default language is English

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => InventoryBloc()),
        BlocProvider(create: (_) => ItemBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kokiku',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: _locale,
        // Automatically use the device's locale
        localizationsDelegates: [
          LocalizationService.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English
          const Locale('id', ''), // Indonesian
        ],
        // Flutter will use the device's locale if 'locale' is not specified
        initialRoute: widget.isFirstLaunch ? '/onboarding' : (user != null) ? '/' : '/landing',
        routes: {
          '/': (context) => MainPage(),
          '/inventory': (context) => InventoryPage(),
          '/shopping': (context) => ShoppingListPage(),
          '/profile': (context) => ProfilePage(),
          '/onboarding': (context) => OnboardingPage(),
          '/landing': (context) => LandingPage(),
          '/addedit': (context) => AddEditItemPage(),
        },
      ),
    );
  }
}