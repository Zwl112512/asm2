import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(order.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderData.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: \$${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${orderData['status'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: orderData['status'] == 'Completed'
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32, thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    final item = orderItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        leading: item['image'].isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            item['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 50);
                            },
                          ),
                        )
                            : const Icon(Icons.image, size: 50),
                        title: Text(item['name']),
                        subtitle: Text(
                          '\$${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 32, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
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
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
