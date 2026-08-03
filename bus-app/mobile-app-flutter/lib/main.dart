import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'utils/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSavedSession()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadSavedPreference()),
      ],
      // Consumer<ThemeProvider> listens for theme changes and rebuilds
      // the MaterialApp with the correct theme when the user toggles.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'HopOn HopOff',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // Uses ThemeProvider's state instead of system setting
            themeMode: themeProvider.isLightMode ? ThemeMode.light : ThemeMode.dark,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

// Decides which screen to show first: while checking for a saved
// session, show a loading indicator; once checked, go straight to
// MainNavigation if a session was found, or LoginScreen if not.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isCheckingSession) {
      return const SplashScreen();
    }

    return authProvider.isLoggedIn ? const MainNavigation() : const LoginScreen();
  }
}