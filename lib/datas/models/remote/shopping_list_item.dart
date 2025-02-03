import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String? id;
  final String itemId;
  final String shoppingListId;
  final String name;
  final String? description;
  final String? categoryId;
  final int quantity;
  final bool isBought;
  final Timestamp createdAt;
  final String accessId;

  ShoppingListItem({
    this.id,
    required this.itemId,
    required this.shoppingListId,
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    required this.isBought,
    required this.createdAt,
    required this.accessId,
  });

  factory ShoppingListItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListItem(
      id: doc.id,
      itemId: data['itemId'],
      shoppingListId: data['shoppingListId'],
      name: data['name'],
      description: data['description'],
      categoryId: data['categoryId'],
      quantity: data['quantity'],
      isBought: data['isBought'],
      createdAt: data['createdAt'],
      accessId: data['accessId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shoppingListId': shoppingListId,
      'itemId': itemId,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'quantity': quantity,
      'isBought': isBought,
      'createdAt': createdAt,
      'accessId': accessId,
    };
  }

  ShoppingListItem copyWith({
    String? id,
    String? shoppingListId,
    String? itemId,
    String? name,
    String? description,
    String? categoryId,
    int? quantity,
    bool? isBought,
    Timestamp? createdAt,
    String? accessId,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
      createdAt: createdAt ?? this.createdAt,
      accessId: accessId ?? this.accessId,
    );
  }
}
