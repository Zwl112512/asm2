import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 添加 Firestore 支持

class PaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentPage({required this.orderId, required this.totalAmount, Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String _paymentMethod = "Credit Card"; // 默认付款方式

  Future<void> _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 准备付款信息
        final paymentInfo = {
          "name": _nameController.text,
          "phone": _phoneController.text,
          "address": _addressController.text,
          "paymentMethod": _paymentMethod,
          "creditCard": {
            "cardNumber": _cardNumberController.text,
            "expiryDate": _expiryDateController.text,
            "cvv": _cvvController.text,
          }
        };

        // 更新 Firestore 中的订单
        await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
          "status": "Completed",
          "paymentInfo": paymentInfo,
        });

        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Order marked as Completed.')),
        );

        // 返回到订单列表页面
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Information')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 用户姓名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
            ),
            // 电话
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
            ),
            // 收货地址
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Shipping Address'),
              validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
            ),
            // 付款方式选择
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              items: const [
                DropdownMenuItem(value: "Credit Card", child: Text("Credit Card")),
                DropdownMenuItem(value: "PayPal", child: Text("PayPal")),
                DropdownMenuItem(value: "Cash on Delivery", child: Text("Cash on Delivery")),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Payment Method'),
            ),
            // 信用卡信息
            if (_paymentMethod == "Credit Card") ...[
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your card number' : null,
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                validator: (value) => value!.isEmpty ? 'Please enter expiry date' : null,
              ),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter CVV' : null,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPayment,
              child: const Text('Submit Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
