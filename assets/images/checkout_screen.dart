import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medlink/location.dart'; // Import your location.dart file

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String shippingAddress = 'Loading...';
  Map<String, String> paymentSummary = {
    'Order Total': 'Loading...',
    'Shipping': 'Loading...',
    'Total': 'Loading...'
  };

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final url = Uri.parse('http://65.108.148.127/api/orderDetails'); // Replace with your endpoint
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          shippingAddress = data['shippingAddress'];
          paymentSummary = {
            'Order Total': data['orderTotal'],
            'Shipping': data['shipping'],
            'Total': data['total'],
          };
        });
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (error) {
      setState(() {
        shippingAddress = 'Failed to load address';
        paymentSummary = {
          'Order Total': 'Failed to load',
          'Shipping': 'Failed to load',
          'Total': 'Failed to load',
        };
      });
      print('Error fetching order details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              shippingAddress,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            buildPaymentSummaryRow('Order Total', paymentSummary['Order Total']!),
            buildPaymentSummaryRow('Shipping', paymentSummary['Shipping']!),
            buildPaymentSummaryRow('Total', paymentSummary['Total']!),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to the LocationScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationScreen()),
                );
              },
              child: Text('Change'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
