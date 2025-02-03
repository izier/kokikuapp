import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  final String? id;
  final String accessId;
  final String name;
  final String? description;
  final Timestamp createdAt;
  final List<String> items;

  ShoppingList({
    this.id,
    required this.accessId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.items,
  });

  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingList(
      id: doc.id,
      accessId: data['accessId'],
      name: data['name'],
      description: data['description'], // Nullable field
      createdAt: data['createdAt'],
      items: List<String>.from(data['items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessId': accessId,
      'name': name,
      'description': description, // Nullable field
      'createdAt': createdAt,
      'items': items,
    };
  }

  ShoppingList copyWith({
    String? id,
    String? accessId,
    String? name,
    String? description,
    Timestamp? createdAt,
    List<String>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      accessId: accessId ?? this.accessId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
