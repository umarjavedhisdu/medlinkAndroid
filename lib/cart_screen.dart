import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'checkout_screen.dart';
import 'constants.dart'; // Import your checkout_screen.dart file

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<CartItem>> fetchCartItems() async {
    try {
      String? token = await getToken();
      final response = await http.get(Uri.parse('$baseUrl/api/cart/get'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['data']== null) {
          OnEmptyCart();
          return [];
        }
        if (body is List) {
          // If the response is a JSON array
          return body.map((json) => CartItem.fromJson(json)).toList();
        } else if (body is Map && body.containsKey('items')) {
          // If the response is a JSON object with an 'items' array
          List<dynamic> itemsJson = body['items'];
          return itemsJson.map((json) => CartItem.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load cart items');
      }
    }
    catch (exception) {
      throw Exception(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              // Display codbanner.png
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Image.network('http://example.com/path/to/codbanner.png'), // Replace with actual URL
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in cart'));
          } else {
            // Create a list of ListTile widgets for each cart item
            List<Widget> cartItemsList = snapshot.data!.map((item) {
              return ListTile(
                leading: Image.network(item.imageUrl),
                title: Text(item.name),
                subtitle: Text('Rs ${item.price}'),
                trailing: Text('${item.quantity}'),
              );
            }).toList();

            // Adding total order and COD information
            double totalOrder = snapshot.data!.fold(0.0, (sum, item) => sum + item.price * item.quantity);
            cartItemsList.add(
              ListTile(
                title: const Text('Order Total:'),
                subtitle: Text('Rs $totalOrder'),
                trailing: const Text('Free'),
              ),
            );
            cartItemsList.add(
              ListTile(
                title: const Text('Cash on Delivery'),
                leading: Image.network('http://example.com/path/to/codbanner.png'), // Replace with actual URL
              ),
            );

            return ListView(children: cartItemsList);
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to checkout_screen.dart when button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
            );
          },
          child: const Text('Proceed to Checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple, // Change the button color to purple
            minimumSize: const Size(double.infinity, 50), // Full width and custom height
          ),
        ),
      ),
    );
  }

  Center OnEmptyCart() {
    return const Center(child: Text('No categories found'));
  }
}

class CartItem {
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      price: json['price'].toDouble(), // Ensure the price is treated as a double
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }
}
