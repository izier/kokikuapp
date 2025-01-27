import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String? description;
  final String category;
  final int quantity;
  final String? regDate;
  final String? expDate;
  final String? location;
  final String? sublocation;
  final String? userId; // Add userId

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.quantity,
    this.regDate,
    this.expDate,
    this.location,
    this.sublocation,
    this.userId, // Include userId in constructor
  });

  // Factory constructor to create an Item from Firestore DocumentSnapshot
  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? 0,
      regDate: data['regDate'] ?? '',
      expDate: data['expDate'] ?? '',
      location: data['location'] ?? '',
      sublocation: data['sublocation'] ?? '',
      userId: data['userId'], // Parse userId from Firestore document
    );
  }

  // Convert Item to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'quantity': quantity,
      'regDate': regDate,
      'expDate': expDate,
      'location': location,
      'sublocation': sublocation,
      'userId': userId,
    };
  }

  // Convert Map<String, dynamic> to Item
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      quantity: map['quantity'],
      regDate: map['regDate'],
      expDate: map['expDate'],
      location: map['location'],
      sublocation: map['sublocation'],
      userId: map['userId'],
    );
  }

  // The copyWith function to create a new Item with updated fields
  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? quantity,
    String? regDate,
    String? expDate,
    String? location,
    String? sublocation,
    String? userId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      regDate: regDate ?? this.regDate,
      expDate: expDate ?? this.expDate,
      location: location ?? this.location,
      sublocation: sublocation ?? this.sublocation,
      userId: userId ?? this.userId,
    );
  }
}
