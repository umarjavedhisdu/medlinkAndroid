import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Location _location = Location();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Current Location'),
        ));
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _saveAddress() async {
    if (_currentLocation != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        return;
      }

      // Create the address object to be sent to the API
      final addressData = {
        "address": _searchController.text,
        "label": "Home",
        "houseNo": _buildingController.text,
        "latitude": _currentLocation!.latitude,
        "longitude": _currentLocation!.longitude
      };

      final response = await http.post(
        Uri.parse('http://65.108.148.127/api/Addresses/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(addressData),
      );
      if (response.statusCode == 200) {
        const SnackBar(content: Text('Address saved successfully'));
      }

      await prefs.setDouble('latitude', _currentLocation!.latitude);
      await prefs.setDouble('longitude', _currentLocation!.longitude);
      await prefs.setString('buildingName', _buildingController.text);
      await prefs.setString('searchAddress', _searchController.text);

      print('Selected location: $_currentLocation');
      print('Search address: ${_searchController.text}');
      print('Building name/house no.: ${_buildingController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully')),
      );
      // Implement logic to save the address to a backend server if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Google Maps Demo'),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Address',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search address',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Building Name / House No.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: _buildingController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Building Name / House No',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to home screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color.fromRGBO(88, 87, 219, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          'Home',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to office screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color.fromRGBO(88, 87, 219, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          'Office',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to other screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color.fromRGBO(88, 87, 219, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          'Other',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromRGBO(88, 87, 219, 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      'Save and Continue',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
