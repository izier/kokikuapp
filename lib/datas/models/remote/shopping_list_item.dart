import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String? id;
  final String name;
  final int quantity;
  final bool isBought;

  ShoppingListItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.isBought,
  });

  factory ShoppingListItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListItem(
      id: doc.id,
      name: data['name'],
      quantity: data['quantity'],
      isBought: data['isBought'],
    );
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> data) {
    return ShoppingListItem(
      id: data['id'],
      name: data['name'],
      quantity: data['quantity'],
      isBought: data['isBought'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'isBought': isBought,
    };
  }

  ShoppingListItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isBought,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
    );
  }
}
