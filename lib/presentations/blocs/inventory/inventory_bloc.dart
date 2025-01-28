import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/services/notification_service.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final _firebaseFirestore = FirebaseFirestore.instance;

  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventory>((event, emit) async {
      emit(InventoryLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        final categoriesSnapshot = await _firebaseFirestore
            .collection('categories')
            .where('userId', isEqualTo: user.uid)
            .get();
        final locationsSnapshot = await _firebaseFirestore
            .collection('locations')
            .where('userId', isEqualTo: user.uid)
            .get();
        final sublocationsSnapshot = await _firebaseFirestore
            .collection('sublocations')
            .where('userId', isEqualTo: user.uid)
            .get();

        final categories = categoriesSnapshot.docs
            .map((doc) => ItemCategory.fromFirestore(doc))
            .toList();
        final locations = locationsSnapshot.docs
            .map((doc) => Location.fromFirestore(doc))
            .toList();
        final sublocations = sublocationsSnapshot.docs
            .map((doc) => Sublocation.fromFirestore(doc))
            .toList();

        final snapshot = await _firebaseFirestore
            .collection('items')
            .where('userId', isEqualTo: user.uid)
            .get();

        final items = snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
        emit(InventoryLoaded(
          items,
          categories,
          locations,
          sublocations,
        ));
      } catch (e, stackTrace) {
        log("Error loading inventory: $e");
        log("Stack trace: $stackTrace");
        emit(InventoryError('Failed to load inventory'));
      }
    });


    on<DeleteInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      try {
        // Delete the item from Firestore
        await _firebaseFirestore.collection('items').doc(event.itemId).delete();

        // Cancel the notification for the deleted item
        final notificationId = event.itemId.hashCode;
        await NotificationService().cancelNotification(notificationId);

        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error deleting item: $e");
        log("Stack trace: $stackTrace");
        emit(InventoryError('Failed to delete item: $e'));
      }
    });

  }
}
