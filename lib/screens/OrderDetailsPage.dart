import 'package:asm2/screens/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(order.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Order not found.'));
          }

          final orderData = snapshot.data!;
          final orderItems = List<Map<String, dynamic>>.from(
            orderData['items'].map((item) {
              return {
                'name': item['name'] ?? 'Unknown Item',
                'price': item['price'] ?? 0.0,
                'quantity': item['quantity'] ?? 1,
                'image': item['image'] ?? '',
              };
            }),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Order #${orderData.id}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Total: \$${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Status: ${orderData['status'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: orderData['status'] == 'Completed'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    final item = orderItems[index];
                    return ListTile(
                      leading: item['image'].isNotEmpty
                          ? Image.network(
                        item['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 50);
                        },
                      )
                          : const Icon(Icons.image, size: 50),
                      title: Text(item['name']),
                      subtitle: Text(
                        '\$${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: orderData['status'] == 'Completed'
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          orderId: orderData.id,
                          totalAmount: orderData['totalAmount'],
                        ),
                      ),
                    );
                  },
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

