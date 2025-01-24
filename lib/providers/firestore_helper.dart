import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collection).add(data);
    } catch (e) {
      print('Firestore add document error: $e');
    }
  }
}
