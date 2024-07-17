import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> cartItemsFuture;

  @override
  void initState() {
    super.initState();
    cartItemsFuture = fetchCartItems();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<CartItem>> fetchCartItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cartItemsJson = prefs.getStringList('cartItems') ?? [];
      return cartItemsJson.map((item) => CartItem.fromJson(json.decode(item))).toList();
    } catch (exception) {
      throw Exception(exception.toString());
    }
  }

  Future<void> updateCartItems(List<CartItem> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cartItems', cartItemsJson);
  }

  Future<void> removeFromCart(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cartItems') ?? [];
    cartItemsJson.removeAt(index);
    await prefs.setStringList('cartItems', cartItemsJson);
    setState(() {
      cartItemsFuture = fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in cart'));
          } else {
            double totalOrder = snapshot.data!.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

            return ListView(
              children: [
                ...snapshot.data!.map((item) {
                  return Card(
                    child: ListTile(
                      // leading: Image.network(
                      //   'http://65.108.148.127${item.product.imageUrl}',
                      //   width: 50,
                      //   height: 50,
                      //   fit: BoxFit.cover,
                      // ),
                      title: Text(item.product.name),
                      subtitle: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: const Color.fromRGBO(88, 87, 219, 1),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) item.quantity--;
                              });
                              updateCartItems(snapshot.data!);
                            },
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: const Color.fromRGBO(88, 87, 219, 1),
                            onPressed: () {
                              setState(() {
                                item.quantity++;
                              });
                              updateCartItems(snapshot.data!);
                            },
                          ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Rs ${item.product.price * item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeFromCart(snapshot.data!.indexOf(item)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/codbanner.png',
                    width: 200,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    title: const Text('Order Total:'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rs $totalOrder'),
                        const Text('Shipping: Free', textAlign: TextAlign.left),
                      ],
                    ),
                    trailing: Text('Total: Rs $totalOrder', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(88, 87, 219, 1),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Proceed to Checkout',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productId'],
      name: json['productName'],
      price: json['productPrice'].toDouble(),
      description: json['productDescription'],
      imageUrl: json['productImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': id,
      'productName': name,
      'productPrice': price,
      'productDescription': description,
      'productImage': imageUrl,
    };
  }
}

void main() {
  runApp(MaterialApp(
    home: CartScreen(),
  ));
}
