import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/datas/models/remote/item.dart';

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
        log('uid: ${user.uid}');

        final snapshot = await _firebaseFirestore
            .collection('items')
            .where('userId', isEqualTo: user.uid)
            .get();

        final items = snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
        emit(InventoryLoaded(items));
      } catch (e, stackTrace) {
        log("Error loading inventory: $e");
        log("Stack trace: $stackTrace");
        emit(InventoryError('Failed to load inventory'));
      }
    });

    on<UpdateInventoryItem>((event, emit) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Ensure the userId is attached to the item when updating
        final item = event.item.copyWith(userId: user.uid);
        await _firebaseFirestore
            .collection('items')
            .doc(event.item.id)
            .update(item.toMap());
        add(LoadInventory()); // Reload inventory after updating
      } catch (e) {
        emit(InventoryError('Failed to update item'));
      }
    });

    on<DeleteInventoryItem>((event, emit) async {
      try {
        await _firebaseFirestore.collection('items').doc(event.itemId).delete();
        add(LoadInventory()); // Reload inventory after deleting
      } catch (e) {
        emit(InventoryError('Failed to delete item'));
      }
    });
  }
}
