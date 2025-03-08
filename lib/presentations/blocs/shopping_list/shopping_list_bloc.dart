import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/shopping_list.dart';
import 'package:kokiku/datas/models/remote/shopping_list_item.dart';
import 'package:kokiku/datas/models/remote/user.dart';

part 'shopping_list_event.dart';
part 'shopping_list_state.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final _firestore = FirebaseFirestore.instance;
  List<String> userAccessIds = [];

  ShoppingListBloc() : super(ShoppingListInitial()) {
    on<LoadShoppingLists>((event, emit) async {
      emit(ShoppingListLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(ShoppingListNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(ShoppingListError(message: 'User not authenticated'));
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
            emit(ShoppingListNoAccessIds());
            return;
          }
        } else {
          emit(ShoppingListNoAccessIds());
          return;
        }

        final accessSnapshot = await _firestore
            .collection('access_ids')
            .where(FieldPath.documentId, whereIn: userAccessIds)
            .get();
        final categoriesSnapshot = await _firestore
            .collection('categories')
            .where('accessId', whereIn: userAccessIds)
            .get();

        final accessIds = accessSnapshot.docs
            .map((doc) => AccessId.fromFirestore(doc))
            .toList();
        final categories = categoriesSnapshot.docs.map(
                (doc) => ItemCategory.fromFirestore(doc)).toList();

        final snapshot = await _firestore
            .collection('shopping_lists')
            .where('accessId', whereIn: userAccessIds)
            .get();

        final shoppingLists = snapshot.docs.map(
            (doc) => ShoppingList.fromFirestore(doc)).toList();

        emit(ShoppingListLoaded(
          accessIds: accessIds,
          shoppingLists: shoppingLists,
          categories: categories,
        ));
      } catch (e) {
        emit(ShoppingListError(message: 'Failed to load shopping lists: $e'));
      }
    });

    on<AddShoppingList>((event, emit) async {
      emit(ShoppingListLoading());
      try{
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(ShoppingListNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(ShoppingListError(message: 'User not authenticated'));
          return;
        }

        final newShoppingList = ShoppingList(
          name: event.name,
          description: event.description,
          createdAt: Timestamp.now(),
          accessId: event.accessId,
          items: [],
        );

        await _firestore.collection('shopping_lists').add(newShoppingList.toMap());

        emit(AddShoppingListSuccess());
        add(LoadShoppingLists());
      } catch (e) {
        emit(ShoppingListError(message: 'Failed to add shopping list: $e'));
      }
    });

    on<LoadShoppingListDetail>((event, emit) async {
      emit(ShoppingListLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(ShoppingListNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(ShoppingListError(message: 'User not authenticated'));
          return;
        }

        final accessSnapshot = await _firestore
            .collection('access_ids')
            .where(FieldPath.documentId, whereIn: userAccessIds)
            .get();
        final itemSnapshot = await _firestore
            .collection('items')
            .where('accessId', whereIn: userAccessIds)
            .get();
        final accessIds = accessSnapshot.docs
            .map((doc) => AccessId.fromFirestore(doc))
            .toList();
        final items = itemSnapshot.docs.map(
            (doc) => Item.fromFirestore(doc)).toList();

        final snapshot = await _firestore
            .collection('shopping_list_items')
            .where('shoppingListId', isEqualTo: event.shoppingListId)
            .get();

        final shoppingListItems = snapshot.docs.map(
            (doc) => ShoppingListItem.fromFirestore(doc)).toList();

        emit(ShoppingListDetailLoaded(accessIds: accessIds, items: items, shoppingListItems: shoppingListItems));
      } catch (e) {
        emit(ShoppingListError(message: 'Failed to load items: $e'));
      }
    });

    on<CreateItem>((event, emit) async {
      emit(ShoppingListLoading());
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(ShoppingListNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(ShoppingListError(message: 'User not authenticated'));
          return;
        }

        final newItem = Item(name: event.name, accessId: event.accessId);
        await _firestore.collection('items').add(newItem.toMap());

        emit(CreateShoppingListItemSuccess());
        add(LoadShoppingListDetail());
        log(state.toString());
      } catch (e) {
        emit(CreateShoppingListItemError(message: 'Failed to create item: $e'));
      }
    });

    // on<AddShoppingListItem>((event, emit) async {
    //   emit(ShoppingListLoading());
    //   try {
    //     final connectivityResult = await Connectivity().checkConnectivity();
    //     if (connectivityResult.contains(ConnectivityResult.none)) {
    //       emit(ShoppingListNoInternet());
    //       return;
    //     }
    //
    //     final user = FirebaseAuth.instance.currentUser;
    //     if (user == null) {
    //       emit(ShoppingListError(message: 'User not authenticated'));
    //       return;
    //     }
    //
    //     final existingItemSnapshot = await _firestore
    //         .collection('items')
    //         .where('name', isEqualTo: event.name)
    //         .where('accessId', isEqualTo: event.accessId)
    //         .limit(1)
    //         .get();
    //
    //     String itemId;
    //     if (existingItemSnapshot.docs.isNotEmpty) {
    //       itemId = existingItemSnapshot.docs.first.id;
    //     } else {
    //       final newItem = Item(name: event.name, accessId: event.accessId, categoryId: event.categoryId!);
    //       final newItemRef = await _firestore.collection('items').add(newItem.toMap());
    //       itemId = newItemRef.id;
    //     }
    //
    //     final shoppingListItem = ShoppingListItem(
    //       shoppingListId: event.shoppingListId,
    //       itemId: itemId,
    //       name: event.name,
    //       quantity: event.quantity,
    //       isBought: false,
    //       createdAt: Timestamp.now(),
    //       accessId: event.accessId,
    //     );
    //
    //     await _firestore.collection('shopping_list_items').add(shoppingListItem.toMap());
    //     emit(AddShoppingListItemSuccess());
    //   } catch (e) {
    //     emit(AddShoppingListItemError(message: 'Failed to add item: $e'));
    //   }
    // });

    on<MarkItemBought>((event, emit) async {
      try {
        emit(ShoppingListLoading());

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          emit(ShoppingListNoInternet());
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(ShoppingListError(message: 'User not authenticated'));
          return;
        }

        await _firestore
            .collection('shopping_list_items')
            .doc(event.itemId)
            .update({'isBought': true});

        emit(MarkItemBoughtSuccess());
      } catch (e) {
        emit(MarkItemBoughtError(message: 'Failed to mark item as bought: $e'));
      }
    });
  }
}
