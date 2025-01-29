import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String id;
  final String shoppingListId;
  final String name;
  final String? description;
  final String? categoryId;
  final int quantity;
  final bool isBought;
  final Timestamp createdAt;

  ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    required this.isBought,
    required this.createdAt,
  });

  factory ShoppingListItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListItem(
      id: doc.id,
      shoppingListId: data['shoppingListId'],
      name: data['name'],
      description: data['description'],
      categoryId: data['categoryId'],
      quantity: data['quantity'],
      isBought: data['isBought'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shoppingListId': shoppingListId,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'quantity': quantity,
      'isBought': isBought,
      'createdAt': createdAt,
    };
  }

  ShoppingListItem copyWith({
    String? id,
    String? shoppingListId,
    String? name,
    String? description,
    String? categoryId,
    int? quantity,
    bool? isBought,
    Timestamp? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
