import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
final TextEditingController _emailController = TextEditingController();

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  Future<void> forgetPassword() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Authenticate/forgot/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailController.text}),
    );

    if (response.statusCode == 200) {
      print(response);
    } else {
      throw Exception('Failed to reset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter Email',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to send OTP to the entered email/phone number
                forgetPassword();
              },
              child: const Text('Send Email'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate back to the login screen
                Navigator.pop(context);
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}