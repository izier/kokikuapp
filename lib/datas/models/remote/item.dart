import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String? id;
  final String name;
  final String accessId;

  Item({
    this.id,
    required this.name,
    required this.accessId,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      accessId: data['accessId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'accessId': accessId,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      accessId: map['accessId'],
    );
  }

  Item copyWith({
    String? id,
    String? name,
    String? accessId,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      accessId: accessId ?? this.accessId,
    );
  }
}
