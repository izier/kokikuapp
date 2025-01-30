import 'package:cloud_firestore/cloud_firestore.dart';

class ItemCategory {
  final String id;
  final String name;
  final String accessId;

  ItemCategory({
    required this.id,
    required this.name,
    required this.accessId,
  });

  // Factory constructor to create Category from Firestore DocumentSnapshot
  factory ItemCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemCategory(
      id: doc.id,
      name: data['name'] ?? '',
      accessId: data['accessId'] ?? '',
    );
  }

  // Method to convert Category to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'accessId': accessId,
    };
  }

  // The copyWith function to create a new ItemCategory with updated fields
  ItemCategory copyWith({
    String? id,
    String? name,
    String? accessId,
  }) {
    return ItemCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      accessId: accessId ?? this.accessId,
    );
  }
}
