import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> product;
  late Future<List<Product>> otherProducts;
  bool isBookmarked = false;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    product = fetchProductDetails(widget.productId);
    otherProducts = fetchOtherProducts();
    checkBookmarkStatus(widget.productId);
  }

  Future<void> checkBookmarkStatus(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isBookmarked = prefs.getBool('bookmark_$productId') ?? false;
    });
  }

  Future<void> toggleBookmark(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isBookmarked = !isBookmarked;
      prefs.setBool('bookmark_$productId', isBookmarked);
      updateBookmarkStatus(productId, isBookmarked);
    });
  }

  Future<void> updateBookmarkStatus(int productId, bool status) async {
    String? token = await getToken();
    if (status == true) {
      final response = await http.post(
        Uri.parse('http://65.108.148.127/api/FavoriteItems/add/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update bookmark status');
      } else {
        print("Added to favourite");
      }
    }
    else if (status == false) {
      final response = await http.post(
        Uri.parse('http://65.108.148.127/api/FavoriteItems/delete/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update bookmark status');
      } else {
        print("Removed from favourite");
      }
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Product> fetchProductDetails(int productId) async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse('http://65.108.148.127/api/Products/get/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body)['data'];
      return Product.fromJson(responseData);
    } else {
      throw Exception(json.decode(response.body)['messages']);
    }
  }

  Future<List<Product>> fetchOtherProducts() async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse('http://65.108.148.127/api/Products/get/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> productsJson = json.decode(response.body)['data'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load other products');
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];
    cartItems.add(json.encode({'product': product.toJson(), 'quantity': quantity}));
    await prefs.setStringList('cartItems', cartItems);

    // Display a snackbar message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center the detailed product
                children: [
                  Center(
                    child: Image.network(
                      'http://65.108.148.127${snapshot.data!.imageUrl}',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${snapshot.data!.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(isBookmarked ? Icons.favorite : Icons.favorite_border, color: isBookmarked ? Colors.red : null),
                        onPressed: () {
                          toggleBookmark(widget.productId);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.data!.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Other Medicines',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Product>>(
                    future: otherProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final product = snapshot.data![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ProductCard(
                                  title: product.name,
                                  imageUrl: product.imageUrl ?? '',
                                  price: product.price,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(
                                          productId: product.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(child: Text('No other products available'));
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      addToCart(snapshot.data!, quantity);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color.fromRGBO(88, 87, 219, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white), // Change text color to white
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
    if (json['productDescription'] != null) {
      return Product(
        id: json['productId'],
        name: json['productName'],
        price: json['productPrice'].toDouble(),
        description: json['productDescription'],
        imageUrl: json['productImage'],
      );
    }
    else {
      return Product(
        id: json['productId'],
        name: json['productName'],
        price: json['productPrice'].toDouble(),
        description: "",
        imageUrl: json['productImage'],
      );
    }

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

class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double price;
  final VoidCallback onTap;

  const ProductCard({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        child: Column(
          children: [
            Image.network('http://65.108.148.127$imageUrl', height: 100, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Rs $price',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
