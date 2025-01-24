import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 添加 Firestore 支持
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    // 准备订单数据
    final orderId = DateTime.now().millisecondsSinceEpoch.toString(); // 唯一订单ID
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
      'status': 'Pending', // 初始订单状态
      'orderDate': Timestamp.now(), // Firestore 时间戳
    };

    try {
      // 写入 Firestore 的 `orders` 集合
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

      // 清空购物车
      cart.clearCart();

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      // 捕获错误并提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // 使用 cart.items 直接作为数据源
    final cartItems = cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final itemKey = cartItems.keys.elementAt(index); // 获取 key
                final item = cartItems[itemKey]!; // 确保 item 不为空
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 50);
                      },
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            cart.decreaseQuantity(itemKey);
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _placeOrder(context, cart),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
