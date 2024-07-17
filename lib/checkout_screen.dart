import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location.dart';
import 'order_screen.dart';
import 'cart_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<String> getSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? buildingName = prefs.getString('buildingName');
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');
    return buildingName != null && latitude != null && longitude != null
        ? '$buildingName, Lat: $latitude, Lng: $longitude'
        : 'No location saved';
  }

  Future<List<CartItem>> fetchCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cartItems') ?? [];
    return cartItemsJson.map((item) => CartItem.fromJson(json.decode(item))).toList();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> placeOrder(double totalOrder, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cartItems') ?? [];
    List<CartItem> cartItems = cartItemsJson.map((item) => CartItem.fromJson(json.decode(item))).toList();

    List<Map<String, dynamic>> orderDetails = cartItems.map((item) {
      return {
        "productId": item.product.id,
        "quantity": item.quantity,
        "price": item.product.price
      };
    }).toList();

    Map<String, dynamic> orderData = {
      "totalAmount": totalOrder,
      "addressId": 2, // Assuming addressId is 2, modify as necessary
      "orderDetails": orderDetails
    };

    String? token = await getToken();

    final response = await http.post(
      Uri.parse('http://65.108.148.127/api/Orders/create'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', },
      body: json.encode(orderData),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrderScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${response.reasonPhrase}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([getSavedLocation(), fetchCartItems()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            String currentLocation = snapshot.data![0];
            List<CartItem> cartItems = snapshot.data![1];

            double totalOrder = cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: Text(currentLocation),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LocationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(88, 87, 219, 1),
                        ),
                        child: const Text('Change', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Order Total'),
                              Text('$totalOrder Rs')
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Shipping'),
                              Text('Free')
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('$totalOrder Rs', style: const TextStyle(fontWeight: FontWeight.bold))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => placeOrder(totalOrder, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(88, 87, 219, 1),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        child: Text('Place Order', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CheckoutScreen(),
  ));
}