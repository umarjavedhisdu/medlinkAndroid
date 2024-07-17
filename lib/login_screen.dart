import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'MainMenuScreen.dart';
import 'constants.dart';
import 'register_screen.dart'; // Import the RegisterScreen.dart file
import 'forgetpassword.dart'; // Import the ForgetPasswordScreen.dart file

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/Authenticate/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        // Save token to shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);

        // Navigate to the main menu screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Login failed. Invalid username or password.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to login. Please try again later.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, // Follow the system theme
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 100,
              ),
              Image.asset(
                'assets/images/homepagelogo.png',
                width: 400,
                height: 32,
              ),
              const Text('Welcome Back',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(88, 87, 219, 1))),
              const Text('Log in to your account',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    labelText: 'Email or Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Color.fromRGBO(88, 87, 219, 1),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                OutlinedButton(
                  onPressed: _login,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(88, 87, 219, 1),
                  ),
                  child: const Text('Log In', style: TextStyle(color: Colors.white)),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
