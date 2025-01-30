import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String? id;
  final String? itemId;
  final String name;
  final String? description;
  final String? categoryId;
  final int quantity;
  final Timestamp? regDate;
  final Timestamp? expDate;
  final String? locationId;
  final String? sublocationId;
  final String accessId;

  InventoryItem({
    this.id,
    this.itemId,
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    this.regDate,
    this.expDate,
    this.locationId,
    this.sublocationId,
    required this.accessId,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      itemId: data['itemId'],
      name: data['name'] ?? 'Unknown',
      description: data['description'],
      categoryId: data['categoryId'],
      quantity: (data['quantity'] ?? 0) as int,
      regDate: data['regDate'] as Timestamp?,
      expDate: data['expDate'] as Timestamp?,
      locationId: data['locationId'],
      sublocationId: data['sublocationId'],
      accessId: data['accessId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'itemId': itemId,
      'description': description,
      'categoryId': categoryId,
      'quantity': quantity,
      'regDate': regDate,
      'expDate': expDate,
      'locationId': locationId,
      'sublocationId': sublocationId,
      'accessId': accessId,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      itemId: map['itemId'],
      name: map['name'],
      description: map['description'],
      categoryId: map['categoryId'],
      quantity: map['quantity'] as int,
      regDate: map['regDate'] as Timestamp?,
      expDate: map['expDate'] as Timestamp?,
      locationId: map['locationId'],
      sublocationId: map['sublocationId'],
      accessId: map['accessId'],
    );
  }

  InventoryItem copyWith({
    String? id,
    String? itemId,
    String? name,
    String? description,
    String? categoryId,
    int? quantity,
    Timestamp? regDate,
    Timestamp? expDate,
    String? locationId,
    String? sublocationId,
    String? accessId,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      regDate: regDate ?? this.regDate,
      expDate: expDate ?? this.expDate,
      locationId: locationId ?? this.locationId,
      sublocationId: sublocationId ?? this.sublocationId,
      accessId: accessId ?? this.accessId,
    );
  }
}
