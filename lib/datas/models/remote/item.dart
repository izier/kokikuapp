import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final int? quantity;
  final String? regDate;
  final String? expDate;
  final String? locationId;
  final String? sublocationId;
  final String? userId;

  Item({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.quantity,
    this.regDate,
    this.expDate,
    this.locationId,
    this.sublocationId,
    this.userId,
  });

  // Factory constructor to create an Item from Firestore DocumentSnapshot
  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      categoryId: data['categoryId'] ?? '',
      quantity: data['quantity'] ?? 0,
      regDate: data['regDate'],
      expDate: data['expDate'],
      locationId: data['locationId'],
      sublocationId: data['sublocationId'],
      userId: data['userId'],
    );
  }

  // Convert Item to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'quantity': quantity,
      'regDate': regDate,
      'expDate': expDate,
      'locationId': locationId,
      'sublocationId': sublocationId,
      'userId': userId,
    };
  }

  // Convert Map<String, dynamic> to Item
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      categoryId: map['categoryId'],
      quantity: map['quantity'],
      regDate: map['regDate'],
      expDate: map['expDate'],
      locationId: map['locationId'],
      sublocationId: map['sublocationId'],
      userId: map['userId'],
    );
  }

  // The copyWith function to create a new Item with updated fields
  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    int? quantity,
    String? regDate,
    String? expDate,
    String? locationId,
    String? sublocationId,
    String? userId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      regDate: regDate ?? this.regDate,
      expDate: expDate ?? this.expDate,
      locationId: locationId ?? this.locationId,
      sublocationId: sublocationId ?? this.sublocationId,
      userId: userId ?? this.userId,
    );
  }
}
