import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 添加 Firestore 支持
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderData = {
      'orderId': orderId,
      'userId': 'user_123', // 示例用户ID
      'items': cart.items.values.map((item) {
        return {
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
          'image': item.image,
        };
      }).toList(),
      'totalAmount': cart.totalAmount,
      'status': 'Pending',
      'orderDate': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final itemKey = cartItems.keys.elementAt(index);
                final item = cartItems[itemKey]!;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 60, color: Colors.grey);
                        },
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.redAccent),
                          onPressed: () {
                            cart.decreaseQuantity(itemKey);
                          },
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            cart.increaseQuantity(itemKey);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () => _placeOrder(context, cart),
              child: const Text(
                'Place Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
