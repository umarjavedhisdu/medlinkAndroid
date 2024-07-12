import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }

  Future<void> _fetchUserProfile() async {
    String? token = await getToken();
    final response = await http.post(Uri.parse('$baseUrl/api/customer/getUserInformation'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Map<String, dynamic> data = responseData['data'];
      setState(() {
        userName = data['fullName'];
        userEmail = data['email'];
      });
    } else {
      // Handle server error
      setState(() {
        userName = 'Anni';
        userEmail = '****@gmail.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        backgroundColor: const Color.fromARGB(255, 11, 12, 80),
      ),
      body: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0] : 'A',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
          ),
          const ListTile(
            leading: Icon(Icons.home),
            title: Text('Your Addresses'),
          ),
          const ListTile(
            leading: Icon(Icons.group),
            title: Text('Invite Friends'),
          ),
          const Divider(),
          const ListTile(
            title: Text('Need Help?'),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
          ),
          const ListTile(
            leading: Icon(Icons.book),
            title: Text('Terms and Conditions'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
