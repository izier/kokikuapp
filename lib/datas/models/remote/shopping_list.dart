import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  final String id;
  final String userId;
  final String name;
  final String? description; // Optional field
  final Timestamp createdAt;
  final List<String> items; // Stores ShoppingListItem IDs

  ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    this.description, // Optional field
    required this.createdAt,
    required this.items,
  });

  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingList(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      description: data['description'], // Nullable field
      createdAt: data['createdAt'],
      items: List<String>.from(data['items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description, // Nullable field
      'createdAt': createdAt,
      'items': items,
    };
  }

  ShoppingList copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    Timestamp? createdAt,
    List<String>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
