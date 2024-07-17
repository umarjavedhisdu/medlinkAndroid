import 'package:flutter/material.dart';
import 'package:medlink/newuserscreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import your new user screen file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedLink Pharmacy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen1(),
    );
  }
}

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({Key? key}) : super(key: key);

  @override
  _SplashScreen1State createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      _checkLoginStatus();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const OnboardingScreen()), // Navigate to NewUserScreen
      // );
    });
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      // If token exists, navigate to the main menu screen
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()), // Navigate to NewUserScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Ensure the background image covers the entire screen
        children: [
          Image.asset(
            'assets/images/splash1.png',
            fit: BoxFit.cover, // Cover the entire screen with the image
          ),
          Positioned(
            // Added button in the top right corner
            top: 20,
            right: 20,
            child: SizedBox(
              width: 80,
              height: 30,
              child: TextButton(
                onPressed: () {
                  // Add the logic to skip the screen
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                  backgroundColor: Colors.transparent,
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
