import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String? id;
  final String name;
  final String accessId;
  final String? categoryId;

  Item({
    this.id,
    required this.name,
    required this.accessId,
    this.categoryId,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      accessId: data['accessId'] ?? '',
      categoryId: data['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'accessId': accessId,
      'categoryId': categoryId,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      accessId: map['accessId'],
      categoryId: map['categoryId'],
    );
  }

  Item copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? accessId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      accessId: accessId ?? this.accessId,
      categoryId: categoryId ?? this.categoryId
    );
  }
}
