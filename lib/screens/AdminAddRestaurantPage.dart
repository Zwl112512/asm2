import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers//image_picker_helper.dart';
import '../providers/firebase_storage_helper.dart';
import '../providers/firestore_helper.dart';

class AdminAddRestaurantPage extends StatefulWidget {
  @override
  _AdminAddRestaurantPageState createState() => _AdminAddRestaurantPageState();
}

class _AdminAddRestaurantPageState extends State<AdminAddRestaurantPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  File? _imageFile;
  bool isAdmin = false; // 用于标记是否为管理员

  @override
  void initState() {
    super.initState();
    _checkAdmin(); // 检查当前用户是否为管理员
  }

  // 检查是否为管理员
  void _checkAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email == 'admin@admin.com') {
      setState(() {
        isAdmin = true; // 当前用户是管理员
      });
    } else {
      setState(() {
        isAdmin = false; // 当前用户不是管理员
      });
    }
  }

  // 选择图片
  Future<void> _pickImage() async {
    final selectedImage = await ImagePickerHelper.pickImageFromGallery();
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  // 保存餐厅信息
  Future<void> _saveRestaurant() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final imageUrl = await FirebaseStorageHelper.uploadImage(_imageFile!, 'restaurant_images');
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed')),
      );
      return;
    }

    await FirestoreHelper.addDocument('restaurants', {
      'name': nameController.text.trim(),
      'location': locationController.text.trim(),
      'image': imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restaurant added successfully')),
    );
    Navigator.pop(context); // 返回上一个页面
  }

  @override
  Widget build(BuildContext context) {
    // 如果不是管理员，显示提示信息
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text('Access Denied')),
        body: Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    // 管理员界面
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Restaurant Name'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                ),
                child: _imageFile == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRestaurant,
              child: Text('Save Restaurant'),
            ),
          ],
        ),
      ),
    );
  }
}
