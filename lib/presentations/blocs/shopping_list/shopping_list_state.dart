part of 'shopping_list_bloc.dart';

abstract class ShoppingListState {}

class ShoppingListInitial extends ShoppingListState {}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingList> shoppingLists;
  final List<ItemCategory> categories;

  ShoppingListLoaded(this.shoppingLists, this.categories);
}

class ShoppingListDetailLoaded extends ShoppingListState {
  final List<ShoppingListItem> shoppingListItems;

  ShoppingListDetailLoaded(this.shoppingListItems);
}

class ShoppingListAdded extends ShoppingListState {
  final ShoppingList shoppingList;

  ShoppingListAdded(this.shoppingList);
}

class ShoppingListItemAdded extends ShoppingListState {
  final ShoppingListItem shoppingListItem;
  final String shoppingListId; // Changed this to shoppingListId for clarity

  ShoppingListItemAdded(this.shoppingListItem, this.shoppingListId);
}

class ShoppingListItemUpdated extends ShoppingListState {
  final ShoppingListItem shoppingListItem;

  // Updated constructor to expect a ShoppingListItem
  ShoppingListItemUpdated(this.shoppingListItem);
}

class ShoppingListItemDeleted extends ShoppingListState {
  final ShoppingListItem shoppingListItem;
  final String shoppingListId; // Changed this to shoppingListId for clarity

  ShoppingListItemDeleted(this.shoppingListItem, this.shoppingListId);
}

class ShoppingListDeleted extends ShoppingListState {}

class ShoppingListError extends ShoppingListState {
  final String message;

  ShoppingListError(this.message);
}

class ShoppingListUpdated extends ShoppingListState {
  final ShoppingList shoppingList;

  ShoppingListUpdated(this.shoppingList);
}
