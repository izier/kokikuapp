import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Sublocation {
  final String id;
  final String locationId;
  final String name;

  Sublocation({
    required this.id,
    required this.locationId,
    required this.name,
  });

  // Factory constructor to create SavingPlace from Firestore DocumentSnapshot
  factory Sublocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sublocation(
      id: doc.id,
      locationId: data['locationId'] ?? '',
      name: data['name'] ?? '',
    );
  }

  // Method to convert SavingPlace to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationId': locationId,
    };
  }

  // The copyWith function to create a new Location with updated fields
  Sublocation copyWith({
    String? id,
    String? locationId,
    String? name,
  }) {
    return Sublocation(
        id: id ?? this.id,
        locationId: locationId ?? this.locationId,
        name: name ?? this.name
    );
  }
}
