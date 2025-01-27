import 'package:flutter/material.dart';
import '../providers/firestore_helper.dart';

class EditRestaurantPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  EditRestaurantPage({required this.docId, required this.data});

  @override
  _EditRestaurantPageState createState() =>
      _EditRestaurantPageState();
}

class _EditRestaurantPageState extends State<EditRestaurantPage> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    locationController = TextEditingController(text: widget.data['location']);
    latitudeController =
        TextEditingController(text: widget.data['latitude'].toString());
    longitudeController =
        TextEditingController(text: widget.data['longitude'].toString());
  }

  Future<void> _saveChanges() async {
    await FirestoreHelper.updateDocument(
      'restaurants',
      widget.docId,
      {
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'latitude': double.parse(latitudeController.text.trim()),
        'longitude': double.parse(longitudeController.text.trim()),
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restaurant updated successfully')),
    );
    Navigator.pop(context); // 返回上一页面
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Restaurant'),
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
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
