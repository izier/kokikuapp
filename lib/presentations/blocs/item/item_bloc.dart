import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:kokiku/constants/services/notification_service.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';

part 'item_event.dart';
part 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final _firestore = FirebaseFirestore.instance;
  List<ItemCategory> categories = [];
  List<Location> locations = [];
  List<Sublocation> sublocations = [];

  ItemBloc() : super(ItemLoading()) {
    // Event handler for loading the item page
    on<LoadItemPage>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        final categoriesSnapshot = await _firestore
            .collection('categories')
            .where('userId', isEqualTo: user.uid)
            .get();
        final locationsSnapshot = await _firestore
            .collection('locations')
            .where('userId', isEqualTo: user.uid)
            .get();
        final sublocationsSnapshot = await _firestore
            .collection('sublocations')
            .where('userId', isEqualTo: user.uid)
            .get();

        categories = categoriesSnapshot.docs
            .map((doc) => ItemCategory.fromFirestore(doc))
            .toList();
        locations = locationsSnapshot.docs
            .map((doc) => Location.fromFirestore(doc))
            .toList();
        sublocations = sublocationsSnapshot.docs
            .map((doc) => Sublocation.fromFirestore(doc))
            .toList();

        emit(ItemLoaded(categories: categories, locations: locations, sublocations: sublocations));
      } catch (e, stackTrace) {
        log("Error loading item data: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to load categories, locations, or sublocations: $e'));
      }
    });

    // Event handler for adding a new item
    on<AddItem>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        final data = event.itemData.copyWith(userId: user.uid);

        // Add the item to Firestore
        final docRef = await _firestore.collection('items').add(data.toMap());

        // Add the document ID to the document data (if you want to store it inside the document)
        await docRef.update({
          'id': docRef.id, // Store the Firestore document ID in the document itself
        });

        final itemId = docRef.id;

        // Schedule a notification for expiring items
        if (event.itemData.expDate != null) {
          final expDate = (event.itemData.expDate as Timestamp).toDate(); // Convert Firestore Timestamp to DateTime
          final reminderDate = expDate.subtract(const Duration(days: 3)); // 3 days before expiry

          if (reminderDate.isAfter(DateTime.now())) {
            await NotificationService().scheduleNotification(
              id: itemId.hashCode, // Unique ID based on the Firestore document ID
              title: 'Reminder: ${event.itemData.name} is expiring soon!',
              body: 'Your item "${event.itemData.name}" will expire on ${DateFormat('dd MMMM yyyy').format(expDate)}.',
              scheduledDate: reminderDate,
            );
          }
        }

        emit(ItemSuccess());
      } catch (e, stackTrace) {
        log("Error adding item: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add item: $e'));
      }
    });

    // Event handler for editing item
    on<EditItem>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        final data = event.itemData.copyWith(userId: user.uid);

        // Update the item in Firestore
        await _firestore.collection('items').doc(event.id).update(data.toMap());

        // Cancel the old notification
        final notificationId = event.id.hashCode;
        await NotificationService().cancelNotification(notificationId);

        // Schedule a notification for expiring items
        if (event.itemData.expDate != null) {
          final expDate = (event.itemData.expDate as Timestamp).toDate(); // Convert Firestore Timestamp to DateTime
          final reminderDate = expDate.subtract(const Duration(days: 3)); // 3 days before expiry

          if (reminderDate.isAfter(DateTime.now())) {
            await NotificationService().scheduleNotification(
              id: event.itemData.id.hashCode, // Unique ID based on the Firestore document ID
              title: 'Reminder: ${event.itemData.name} is expiring soon!',
              body: 'Your item "${event.itemData.name}" will expire on ${DateFormat('dd MMMM yyyy').format(expDate)}.',
              scheduledDate: reminderDate,
            );
          }
        }

        emit(ItemSuccess());
      } catch (e, stackTrace) {
        log("Error editing item: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to edit item: $e'));
      }
    });

    // Event handler for deleting item
    on<DeleteItem>((event, emit) async {
      emit(ItemLoading());
      try {
        // Delete the item from Firestore
        await _firestore.collection('items').doc(event.id).delete();

        // Cancel the notification for the deleted item
        final notificationId = event.id.hashCode;
        await NotificationService().cancelNotification(notificationId);
      } catch (e, stackTrace) {
        log("Error deleting item: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to delete item: $e'));
      }
    });

    // Event handler for adding a new category
    on<AddCategory>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        await _firestore.collection('categories').add({
          'name': event.categoryName,
          'userId': user.uid,
        });
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error adding category: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add category: $e'));
      }
    });

    // Event handler for adding a new location
    on<AddLocation>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        await _firestore.collection('locations').add({
          'name': event.name,
          'userId': user.uid,
        });
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error adding location: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add location: $e'));
      }
    });

    // Event handler for adding a new sublocation
    on<AddSublocation>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        await _firestore.collection('sublocations').add({
          'locationId': event.locationId,
          'name': event.name,
          'userId': user.uid,
        });
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error adding sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add sublocation: $e'));
      }
    });

    // Event handler for editing a category
    on<EditCategory>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        // Update the category in Firestore
        await _firestore.collection('categories').doc(event.categoryId).update({
          'name': event.categoryName,
        });

        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error editing category: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to edit category: $e'));
      }
    });

    // Event handler for deleting a category
    on<DeleteCategory>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        // Delete the category from Firestore
        await _firestore.collection('categories').doc(event.categoryId).delete();

        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error deleting category: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to delete category: $e'));
      }
    });

    // Event handler for editing a location
    on<EditLocation>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        // Update the location in Firestore
        await _firestore.collection('locations').doc(event.locationId).update({
          'name': event.name,
        });

        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error editing location: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to edit location: $e'));
      }
    });

    // Event handler for deleting a location
    on<DeleteLocation>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        // Delete the location from Firestore
        await _firestore.collection('locations').doc(event.locationId).delete();

        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error deleting location: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to delete location: $e'));
      }
    });

    // Event handler for editing a sublocation
    on<EditSublocation>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        // Update the sublocation in Firestore
        await _firestore.collection('sublocations').doc(event.sublocationId).update({
          'name': event.name,
        });

        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error editing sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to edit sublocation: $e'));
      }
    });

    // Event handler for deleting a sublocation
    on<DeleteSublocation>((event, emit) async {
      emit(ItemLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          emit(ItemError('User not authenticated'));
          return;
        }

        // Delete the sublocation from Firestore
        await _firestore.collection('sublocations').doc(event.sublocationId).delete();

        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error deleting sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to delete sublocation: $e'));
      }
    });

  }
}
