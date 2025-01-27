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

        await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
          "status": "Completed",
          "paymentInfo": paymentInfo,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Order marked as Completed.')),
        );

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
      appBar: AppBar(
        title: const Text('Payment Information'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 标题
              Text(
                'Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // 用户姓名
              _buildInputField(
                controller: _nameController,
                labelText: 'Full Name',
                icon: Icons.person,
              ),
              // 电话
              _buildInputField(
                controller: _phoneController,
                labelText: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              // 收货地址
              _buildInputField(
                controller: _addressController,
                labelText: 'Shipping Address',
                icon: Icons.location_on,
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
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
              const SizedBox(height: 20),
              // 信用卡信息
              if (_paymentMethod == "Credit Card") ...[
                _buildInputField(
                  controller: _cardNumberController,
                  labelText: 'Card Number',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                ),
                _buildInputField(
                  controller: _expiryDateController,
                  labelText: 'Expiry Date (MM/YY)',
                  icon: Icons.date_range,
                ),
                _buildInputField(
                  controller: _cvvController,
                  labelText: 'CVV',
                  icon: Icons.lock,
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 30),
              // 提交按钮
              ElevatedButton(
                onPressed: _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit Payment',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 公共输入框构造
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $labelText' : null,
      ),
    );
  }
}
