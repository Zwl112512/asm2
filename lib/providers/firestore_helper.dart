import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collection).add(data);
    } catch (e) {
      print('Firestore add document error: $e');
    }
  }

  static Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).update(data);
    } catch (e) {
      print('Firestore update document error: $e');
    }
  }

  static Future<void> deleteDocument(String collection, String docId) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Firestore delete document error: $e');
    }
  }
}
