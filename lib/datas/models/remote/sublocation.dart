import 'package:cloud_firestore/cloud_firestore.dart';

class Sublocation {
  final String id;
  final String locationId;
  final String name;
  final String accessId;

  Sublocation({
    required this.id,
    required this.locationId,
    required this.name,
    required this.accessId,
  });

  // Factory constructor to create SavingPlace from Firestore DocumentSnapshot
  factory Sublocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sublocation(
      id: doc.id,
      locationId: data['locationId'] ?? '',
      name: data['name'] ?? '',
      accessId: data['accessId'] ?? '',
    );
  }

  // Method to convert SavingPlace to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationId': locationId,
      'accessId': accessId,
    };
  }

  // The copyWith function to create a new Location with updated fields
  Sublocation copyWith({
    String? id,
    String? locationId,
    String? name,
    String? accessId,
  }) {
    return Sublocation(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      accessId: accessId ?? this.accessId,
    );
  }
}
