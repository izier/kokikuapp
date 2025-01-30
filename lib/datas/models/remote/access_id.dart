import 'package:cloud_firestore/cloud_firestore.dart';

class AccessId {
  final String id;
  final String name;
  final DateTime createdAt;

  AccessId({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory AccessId.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccessId(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
