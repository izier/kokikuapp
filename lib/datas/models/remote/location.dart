import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String id;
  final String name;
  final String accessId;

  Location({
    required this.id,
    required this.name,
    required this.accessId,
  });

  // Factory constructor to create SavingPlace from Firestore DocumentSnapshot
  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      name: data['name'] ?? '',
      accessId: data['accessId'] ?? '',
    );
  }

  // Method to convert SavingPlace to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'accessId': accessId,
    };
  }

  // The copyWith function to create a new Location with updated fields
  Location copyWith({
    String? id,
    String? name,
    String? accessId,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      accessId: accessId ?? this.accessId
    );
  }
}
