import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addItem({
    required String name,
    String? description,
    required DateTime buyDate,
    required DateTime expiredDate,
    String? category,
    required int quantity,
  }) async {
    try {
      await _firestore.collection('items').add({
        'name': name,
        'description': description,
        'buyDate': buyDate,
        'expiredDate': expiredDate,
        'category': category,
        'quantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error adding item: $e");
    }
  }
}
