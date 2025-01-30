import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kokiku/constants/services/notification_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/inventory_item.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/datas/models/remote/user.dart';
import 'package:uuid/uuid.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final _firestore = FirebaseFirestore.instance;
  List<String> userAccessIds = [];

  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventory>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        final userSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          final userModel = UserModel.fromFirestore(userSnapshot.data()!, user.uid);
          userAccessIds = userModel.accessIds;
          if (userAccessIds.isEmpty) {
            emit(InventoryNoAccessIds());
            return;
          }
        } else {
          emit(InventoryNoAccessIds());
          return;
        }

        final accessSnapshot = await _firestore
            .collection('accessIds')
            .where(FieldPath.documentId, whereIn: userAccessIds)
            .get();
        final categoriesSnapshot = await _firestore
            .collection('categories')
            .where('accessId', whereIn: userAccessIds)
            .get();
        final locationsSnapshot = await _firestore
            .collection('locations')
            .where('accessId', whereIn: userAccessIds)
            .get();
        final sublocationsSnapshot = await _firestore
            .collection('sublocations')
            .where('accessId', whereIn: userAccessIds)
            .get();

        final accessIds = accessSnapshot.docs
            .map((doc) => AccessId.fromFirestore(doc))
            .toList();
        final categories = categoriesSnapshot.docs
            .map((doc) => ItemCategory.fromFirestore(doc))
            .toList();
        final locations = locationsSnapshot.docs
            .map((doc) => Location.fromFirestore(doc))
            .toList();
        final sublocations = sublocationsSnapshot.docs
            .map((doc) => Sublocation.fromFirestore(doc))
            .toList();

        final snapshot = await _firestore
            .collection('inventory_items')
            .where('accessId', whereIn: userAccessIds)
            .get();

        final inventoryItems = snapshot.docs.map(
                (doc) => InventoryItem.fromFirestore(doc)).toList();

        emit(InventoryLoaded(
          accessIds: accessIds,
          inventoryItems: inventoryItems,
          categories: categories,
          locations: locations,
          sublocations: sublocations,
        ));
      } catch (e, stackTrace) {
        log("Error loading inventory: $e");
        log("Stack trace: $stackTrace");
        emit(InventoryError('Failed to load inventory'));
      }
    });

    on<AddInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        final existingItemSnapshot = await _firestore
            .collection('items')
            .where('name', isEqualTo: event.name)
            .where('accessId', isEqualTo: event.accessId)
            .limit(1)
            .get();

        String itemId;
        if (existingItemSnapshot.docs.isNotEmpty) {
          itemId = existingItemSnapshot.docs.first.id;
        } else {
          final newItem = Item(name: event.name, accessId: event.accessId);
          final newItemRef = await _firestore.collection('items').add(newItem.toMap());
          itemId = newItemRef.id;
        }

        final inventoryItem = InventoryItem(
          name: event.name,
          itemId: itemId,
          description: event.description,
          categoryId: event.categoryId,
          quantity: event.quantity,
          regDate: event.regDate,
          expDate: event.expDate,
          locationId: event.locationId,
          sublocationId: event.sublocationId,
          accessId: event.accessId,
        );

        final docRef = await _firestore.collection('inventory_items').add(inventoryItem.toMap());
        final inventoryItemId = docRef.id;

        if (inventoryItem.expDate != null) {
          final expDate = (inventoryItem.expDate as Timestamp).toDate();
          final reminderDate = expDate.subtract(const Duration(days: 3));

          if (reminderDate.isAfter(DateTime.now())) {
            await NotificationService().scheduleNotification(
              id: inventoryItemId.hashCode,
              title: 'Reminder: ${inventoryItem.name} is expiring soon!',
              body: 'Your item "${inventoryItem.name}" will expire on ${DateFormat('dd MMMM yyyy').format(expDate)}.',
              scheduledDate: reminderDate,
            );
          }
        }

        emit(AddInventoryItemSuccess());
      } catch (e, stackTrace) {
        log("Error adding item: $e");
        log("Stack trace: $stackTrace");
        emit(AddInventoryItemError('Failed to add item: $e'));
      }
    });

    on<EditInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        final item = Item(
          name: event.name,
          accessId: event.accessId,
        );

        await _firestore.collection('inventory_items').doc(event.id)
            .update(item.toMap());

        final inventoryItem = InventoryItem(
          name: event.name,
          description: event.description,
          categoryId: event.categoryId,
          quantity: event.quantity,
          regDate: event.regDate,
          expDate: event.expDate,
          locationId: event.locationId,
          sublocationId: event.sublocationId,
          accessId: event.accessId,
        );

        await _firestore.collection('inventory_items').doc(event.id)
            .update(inventoryItem.toMap());

        final notificationId = event.id.hashCode;
        await NotificationService().cancelNotification(notificationId);

        if (inventoryItem.expDate != null) {
          final expDate = (inventoryItem.expDate as Timestamp).toDate();
          final reminderDate = expDate.subtract(const Duration(days: 3));

          if (reminderDate.isAfter(DateTime.now())) {
            await NotificationService().scheduleNotification(
              id: event.id.hashCode, // Unique ID based on the Firestore document ID
              title: 'Reminder: ${inventoryItem.name} is expiring soon!',
              body: 'Your item "${inventoryItem.name}" will expire on ${DateFormat('dd MMMM yyyy').format(expDate)}.',
              scheduledDate: reminderDate,
            );
          }
        }

        emit(EditInventoryItemSuccess());
      } catch (e, stackTrace) {
        log("Error editing item: $e");
        log("Stack trace: $stackTrace");
        emit(EditInventoryItemError('Failed to edit item: $e'));
      }
    });

    on<DeleteInventoryItem>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        await _firestore.collection('inventory_items')
            .doc(event.inventoryItemId).delete();

        final notificationId = event.inventoryItemId.hashCode;
        await NotificationService().cancelNotification(notificationId);

        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error deleting item: $e");
        log("Stack trace: $stackTrace");
        emit(InventoryError('Failed to delete item: $e'));
      }
    });

    on<AddAccessId>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        String? accessIdName = event.name;

        String newAccessId = Uuid().v4();
        AccessId newAccess = AccessId(
          id: newAccessId,
          name: accessIdName,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('accessIds').doc(newAccessId).set(newAccess.toFirestore());

        await _firestore.collection('users').doc(user.uid).update({
          'accessIds': FieldValue.arrayUnion([newAccessId])
        });
        emit(AddAccessIdSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error adding access id: $e");
        log("Stack trace: $stackTrace");
        emit(EditInventoryItemError('Failed to add access id: $e'));
      }
    });

    on<AddCategory>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }
        await _firestore.collection('categories').add({
          'name': event.categoryName,
          'accessId': event.accessId,
        });
        emit(AddCategoriesSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error adding category: $e");
        log("Stack trace: $stackTrace");
        emit(AddCategoriesError('Failed to add category: $e'));
      }
    });

    on<AddLocation>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        await _firestore.collection('locations').add({
          'name': event.name,
          'accessId': event.accessId,
        });

        emit(AddLocationSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error adding location: $e");
        log("Stack trace: $stackTrace");
        emit(AddLocationError('Failed to add location: $e'));
      }
    });

    on<AddSublocation>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        await _firestore.collection('sublocations').add({
          'locationId': event.locationId,
          'name': event.name,
          'accessId': event.accessId,
        });

        emit(AddSubLocationSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error adding sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(AddSubLocationError('Failed to add sublocation: $e'));
      }
    });

    on<EditCategory>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Update the category in Firestore
        await _firestore.collection('categories').doc(event.categoryId).update({
          'name': event.categoryName,
        });

        emit(EditCategoriesSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error editing category: $e");
        log("Stack trace: $stackTrace");
        emit(EditCategoriesError('Failed to edit category: $e'));
      }
    });

    // Event handler for deleting a category
    on<DeleteCategory>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Delete the category from Firestore
        await _firestore.collection('categories').doc(event.categoryId).delete();

        emit(DeleteCategoriesSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error deleting category: $e");
        log("Stack trace: $stackTrace");
        emit(DeleteCategoriesError('Failed to delete category: $e'));
      }
    });

    // Event handler for editing a location
    on<EditLocation>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Update the location in Firestore
        await _firestore.collection('locations').doc(event.locationId).update({
          'name': event.name,
        });

        emit(EditLocationSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error editing location: $e");
        log("Stack trace: $stackTrace");
        emit(EditCategoriesError('Failed to edit location: $e'));
      }
    });

    // Event handler for deleting a location
    on<DeleteLocation>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Delete the location from Firestore
        await _firestore.collection('locations').doc(event.locationId).delete();

        emit(DeleteLocationSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error deleting location: $e");
        log("Stack trace: $stackTrace");
        emit(DeleteLocationError('Failed to delete location: $e'));
      }
    });

    // Event handler for editing a sublocation
    on<EditSublocation>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Update the sublocation in Firestore
        await _firestore.collection('sublocations').doc(event.sublocationId).update({
          'name': event.name,
        });

        emit(EditSubLocationSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error editing sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(EditCategoriesError('Failed to edit sublocation: $e'));
      }
    });

    // Event handler for deleting a sublocation
    on<DeleteSublocation>((event, emit) async {
      emit(InventoryLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(InventoryNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(InventoryError('User not authenticated'));
          return;
        }

        // Delete the sublocation from Firestore
        await _firestore.collection('sublocations').doc(event.sublocationId).delete();

        emit(EditSubLocationSuccess());
        add(LoadInventory());
      } catch (e, stackTrace) {
        log("Error deleting sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(EditCategoriesError('Failed to delete sublocation: $e'));
      }
    });

  }
}
