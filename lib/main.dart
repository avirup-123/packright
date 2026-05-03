import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'providers/trip_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/trip_input_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/checklist_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/congratulations_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob (Android/iOS only)
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  // Initialize the TripProvider (which also initializes Hive and StorageService)
  final tripProvider = TripProvider();
  await tripProvider.init();

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider; // Wait for initial load

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => tripProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const PackRightApp(),
    ),
  );
}

class PackRightApp extends StatelessWidget {
  const PackRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Set status bar based on theme mode
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeProvider.isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: themeProvider.isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
        );

        return MaterialApp(
          title: 'PackRight',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/trip-input': (context) => const TripInputScreen(),
            '/loading': (context) => const LoadingScreen(),
            '/checklist': (context) => const ChecklistScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/congratulations': (context) => const CongratulationsScreen(),
          },
        );
      },
    );
  }
}