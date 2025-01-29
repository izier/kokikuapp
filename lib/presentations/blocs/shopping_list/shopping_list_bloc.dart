import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/shopping_list.dart';
import 'package:kokiku/datas/models/remote/shopping_list_item.dart';

part 'shopping_list_state.dart';
part 'shopping_list_event.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  ShoppingListBloc() : super(ShoppingListInitial()) {
    // Load shopping lists (the list of all shopping lists)
    on<LoadShoppingList>((event, emit) async {
      try {
        emit(ShoppingListLoading());

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(ShoppingListError('User not authenticated'));
          return;
        }

        final categoriesSnapshot = await _firestore
            .collection('categories')
            .where('userId', isEqualTo: user.uid)
            .get();
        final categories = categoriesSnapshot.docs
            .map((doc) => ItemCategory.fromFirestore(doc))
            .toList();

        final snapshot = await _firestore
            .collection('shopping_lists')
            .where('userId', isEqualTo: _user!.uid)
            .get();

        final shoppingLists = snapshot.docs
            .map((doc) => ShoppingList.fromFirestore(doc))
            .toList();

        emit(ShoppingListLoaded(shoppingLists, categories));
      } catch (e) {
        emit(ShoppingListError('Failed to load shopping lists: $e'));
      }
    });

    // Load details of a specific shopping list (the items within it)
    on<LoadShoppingListDetail>((event, emit) async {
      try {
        emit(ShoppingListLoading());

        final snapshot = await _firestore
            .collection('shopping_list_items')
            .where('shoppingListId', isEqualTo: event.shoppingListId)
            .get();

        final shoppingListItems = snapshot.docs
            .map((doc) => ShoppingListItem.fromFirestore(doc))
            .toList();

        emit(ShoppingListDetailLoaded(shoppingListItems));
      } catch (e) {
        emit(ShoppingListError('Failed to load shopping list details: $e'));
      }
    });

    // Add a new shopping list with items
    on<AddShoppingList>((event, emit) async {
      try {
        final shoppingListRef = _firestore.collection('shopping_lists').doc();

        final shoppingList = ShoppingList(
          id: shoppingListRef.id,
          userId: _user!.uid,
          description: event.description,
          name: event.name,
          createdAt: Timestamp.now(),
          items: [], // Items will be added later
        );

        // Add shopping list to Firestore
        await shoppingListRef.set(shoppingList.toMap());

        emit(ShoppingListAdded(shoppingList));
      } catch (e) {
        emit(ShoppingListError('Failed to add shopping list: $e'));
      }
    });

    // Add items to a specific shopping list
    on<AddItemToShoppingList>((event, emit) async {
      try {
        final shoppingListItemRef = _firestore.collection('shopping_list_items').doc();
        final shoppingListItem = ShoppingListItem(
          id: shoppingListItemRef.id,
          name: event.shoppingListItem.name,
          description: event.shoppingListItem.description,
          categoryId: event.shoppingListItem.categoryId,
          quantity: event.shoppingListItem.quantity,
          isBought: false,
          createdAt: Timestamp.now(),
          shoppingListId: event.shoppingListId,
        );

        // Save shopping list item to Firestore
        await shoppingListItemRef.set(shoppingListItem.toMap());

        // Update the shopping list to include the new item
        await _firestore.collection('shopping_lists').doc(event.shoppingListId).update({
          'items': FieldValue.arrayUnion([shoppingListItemRef.id]),
        });

        emit(ShoppingListItemAdded(shoppingListItem, event.shoppingListId));
      } catch (e) {
        emit(ShoppingListError('Failed to add item to shopping list: $e'));
      }
    });

    // Mark an item as bought
    on<MarkItemBought>((event, emit) async {
      try {
        // Get the shopping list item from Firestore
        final doc = await _firestore
            .collection('shopping_list_items')
            .doc(event.shoppingListItemId)
            .get();

        if (doc.exists) {
          // Mark item as bought
          await _firestore
              .collection('shopping_list_items')
              .doc(event.shoppingListItemId)
              .update({'is_bought': true});

          // Retrieve the updated shopping list item
          final shoppingListItem = ShoppingListItem.fromFirestore(doc);

          // Emit the updated item state
          emit(ShoppingListItemUpdated(shoppingListItem));
        }
      } catch (e) {
        emit(ShoppingListError('Failed to mark item as bought: $e'));
      }
    });


    // Remove an item from a shopping list
    on<RemoveItemFromShoppingList>((event, emit) async {
      try {
        await _firestore
            .collection('shopping_list_items')
            .doc(event.shoppingListItem.id)
            .delete();

        // Remove the item from the shopping list document's items array
        await _firestore.collection('shopping_lists').doc(event.shoppingListId).update({
          'items': FieldValue.arrayRemove([event.shoppingListItem.id]),
        });

        emit(ShoppingListItemDeleted(event.shoppingListItem, event.shoppingListId));
      } catch (e) {
        emit(ShoppingListError('Failed to delete item from shopping list: $e'));
      }
    });

    // Delete a shopping list (including all its items)
    on<DeleteShoppingList>((event, emit) async {
      try {
        // Delete all shopping list items
        final itemsSnapshot = await _firestore
            .collection('shopping_list_items')
            .where('shoppingListId', isEqualTo: event.shoppingListId)
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          await itemDoc.reference.delete();
        }

        // Delete the shopping list
        await _firestore.collection('shopping_lists').doc(event.shoppingListId).delete();

        emit(ShoppingListDeleted());
      } catch (e) {
        emit(ShoppingListError('Failed to delete shopping list: $e'));
      }
    });

    on<UpdateShoppingList>((event, emit) async {
      try {
        // Update the shopping list in Firestore
        final shoppingListRef = _firestore.collection('shopping_lists').doc(event.id);

        // Prepare the updated data
        final updatedData = {
          'name': event.name,
          'description': event.description ?? '',
        };

        // Update the shopping list document
        await shoppingListRef.update(updatedData);

        // Emit the updated shopping list state (you can choose to fetch updated data here)
        final updatedShoppingList = ShoppingList(
          id: event.id,
          userId: _user!.uid,
          name: event.name,
          createdAt: Timestamp.now(),
          items: [], // Or fetch items if necessary
          description: event.description ?? '',
        );

        emit(ShoppingListUpdated(updatedShoppingList));
      } catch (e) {
        emit(ShoppingListError('Failed to update shopping list: $e'));
      }
    });
  }
}
