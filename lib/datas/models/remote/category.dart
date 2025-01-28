import 'package:cloud_firestore/cloud_firestore.dart';

class ItemCategory {
  final String id;
  final String name;
  final String userId;

  ItemCategory({
    required this.id,
    required this.name,
    required this.userId,
  });

  // Factory constructor to create Category from Firestore DocumentSnapshot
  factory ItemCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemCategory(
      id: doc.id,
      name: data['name'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  // Method to convert Category to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
    };
  }

  // The copyWith function to create a new ItemCategory with updated fields
  ItemCategory copyWith({
    String? id,
    String? name,
    String? userId,
  }) {
    return ItemCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
    );
  }
}
