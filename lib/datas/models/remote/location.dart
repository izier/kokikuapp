import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String id;
  final String name;
  final String userId;

  Location({
    required this.id,
    required this.name,
    required this.userId,
  });

  // Factory constructor to create SavingPlace from Firestore DocumentSnapshot
  factory Location.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Location(
      id: doc.id,
      name: data['name'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  // Method to convert SavingPlace to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
    };
  }

  // The copyWith function to create a new Location with updated fields
  Location copyWith({
    String? id,
    String? name,
    String? userId,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId
    );
  }
}
