import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

  ItemBloc() : super(ItemInitial()) {
    // Event handler for loading the item page
    on<LoadItemPage>((event, emit) async {
      emit(ItemLoading());
      try {
        final categoriesSnapshot = await _firestore.collection('categories').get();
        final locationsSnapshot = await _firestore.collection('locations').get();
        final sublocationsSnapshot = await _firestore.collection('sublocations').get();

        // Map Firestore documents to objects
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
        final item = event.itemData.copyWith(userId: user.uid);
        await _firestore.collection('items').add(item.toMap());
        emit(ItemSuccess());
      } catch (e, stackTrace) {
        log("Error adding item: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add item: $e'));
      }
    });

    // Event handler for editing an existing item
    on<EditItem>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('items').doc(event.itemId).update(event.itemData.toMap());
        emit(ItemSuccess());
      } catch (e, stackTrace) {
        log("Error editing item: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to edit item: $e'));
      }
    });

    // Event handler for adding a new category
    on<AddCategory>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('categories').add({'name': event.categoryName});
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error adding category: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add category: $e'));
      }
    });

    // Event handler for editing a category
    on<EditCategory>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('categories').doc(event.categoryId).update({'name': event.categoryName});
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
        await _firestore.collection('categories').doc(event.categoryId).delete();
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error deleting category: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to delete category: $e'));
      }
    });

    // Event handler for adding a new location
    on<AddLocation>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('locations').add({'name': event.name});
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error adding location: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add location: $e'));
      }
    });

    // Event handler for editing a location
    on<EditLocation>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('locations').doc(event.locationId).update({'name': event.name});
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
        await _firestore.collection('locations').doc(event.locationId).delete();
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error deleting location: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to delete location: $e'));
      }
    });

    // Event handler for adding a new sublocation
    on<AddSublocation>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('sublocations').add({'locationId': event.locationId, 'name': event.name});
        emit(ItemSuccess());
        add(LoadItemPage());
      } catch (e, stackTrace) {
        log("Error adding sublocation: $e");
        log("Stack trace: $stackTrace");
        emit(ItemError('Failed to add sublocation: $e'));
      }
    });

    // Event handler for editing a sublocation
    on<EditSublocation>((event, emit) async {
      emit(ItemLoading());
      try {
        await _firestore.collection('sublocations').doc(event.sublocationId).update({'name': event.name});
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
