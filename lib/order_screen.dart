import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'MainMenuScreen.dart';
import 'constants.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Order>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Orders/get'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'page': 0, 'pageSize': 10}),
    );

    if (response.statusCode == 200) {
      List<dynamic> ordersJson = json.decode(response.body)['data'];
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return OrderCard(order: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

class Order {
  final int orderId;
  final String orderNo;
  final String fullName;
  final int orderStatusId;
  final String orderStatusName;
  final int totalAmount;
  final String createdDate;
  final String address;
  final String createdBy;

  Order({
    required this.orderId,
    required this.orderNo,
    required this.fullName,
    required this.orderStatusId,
    required this.orderStatusName,
    required this.totalAmount,
    required this.createdDate,
    required this.address,
    required this.createdBy,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      orderNo: json['orderNo'],
      fullName: json['fullName'],
      orderStatusId: json['orderStatusId'],
      orderStatusName: json['orderStatusName'],
      totalAmount: json['totalAmount'],
      createdDate: json['createdDate'],
      address: json['address'],
      createdBy: json['createdBy'],
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Order No: ${order.orderNo}'),
        subtitle: Text('Customer: ${order.fullName}\nTotal: \$${order.totalAmount}'),
        trailing: Text(order.orderStatusName),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order.orderId),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  Future<OrderDetail> fetchOrderDetail() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Orders/detail/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OrderDetail.fromJson(data['data']);
    } else {
      throw Exception('Failed to load order detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<OrderDetail>(
        future: fetchOrderDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No order details found'));
          } else {
            final orderDetail = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${orderDetail.orderId}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Customer: ${orderDetail.fullName}'),
                  Text('Phone: ${orderDetail.phoneNumber}'),
                  Text('Address: ${orderDetail.address}'),
                  Text('Created By: ${orderDetail.createdBy}'),
                  Text('Total Items: ${orderDetail.totalItems}'),
                  Text('Total Amount: \$${orderDetail.totalAmount}'),
                  Text('Created Date: ${orderDetail.createdDate}'),
                  SizedBox(height: 16),
                  Text('Products:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderDetail.productSummary.length,
                      itemBuilder: (context, index) {
                        final product = orderDetail.productSummary[index];
                        return ListTile(
                          title: Text(product.productName),
                          subtitle: Text('Quantity: ${product.quantity} - Price: \$${product.productPrice}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class OrderDetail {
  final int orderId;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String createdBy;
  final int totalItems;
  final int totalAmount;
  final String createdDate;
  final List<ProductSummary> productSummary;

  OrderDetail({
    required this.orderId,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.createdBy,
    required this.totalItems,
    required this.totalAmount,
    required this.createdDate,
    required this.productSummary,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['orderDetail']['orderId'],
      fullName: json['customerDetail']['fullName'],
      phoneNumber: json['customerDetail']['phoneNumber'],
      address: json['customerDetail']['address'],
      createdBy: json['customerDetail']['createdBy'],
      totalItems: json['orderDetail']['totalItems'],
      totalAmount: json['orderDetail']['total'],
      createdDate: json['orderDetail']['createdDate'],
      productSummary: (json['productSummary'] as List)
          .map((product) => ProductSummary.fromJson(product))
          .toList(),
    );
  }
}

class ProductSummary {
  final int orderId;
  final String productName;
  final int quantity;
  final int productPrice;

  ProductSummary({
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      orderId: json['orderId'],
      productName: json['productName'],
      quantity: json['quantity'],
      productPrice: json['productPrice'],
    );
  }
}
