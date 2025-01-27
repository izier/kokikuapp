import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String id;
  final String name;

  Location({
    required this.id,
    required this.name,
  });

  // Factory constructor to create SavingPlace from Firestore DocumentSnapshot
  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  // Method to convert SavingPlace to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // The copyWith function to create a new Location with updated fields
  Location copyWith({
    String? id,
    String? name,
  }) {
    return Location(
        id: id ?? this.id,
        name: name ?? this.name
    );
  }
}
