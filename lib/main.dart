import 'package:flutter/material.dart';
import 'package:medlink/SplashScreen1.dart';
import 'package:medlink/login_screen.dart';
import 'package:medlink/register_screen.dart';
import 'package:medlink/checkout_screen.dart';
import 'package:medlink/profiles_screen.dart';

import 'MainMenuScreen.dart'; // Import ProfilesScreen from profiles_screen.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen1(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfilesScreen(), // Use ProfilesScreen from profiles_screen.dart
        '/main': (context) => const MainMenuScreen(),
      },
    );
  }
}
