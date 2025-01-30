part of 'shopping_list_bloc.dart';

abstract class ShoppingListEvent {}

class LoadShoppingList extends ShoppingListEvent {
  LoadShoppingList();
}

class LoadShoppingListDetail extends ShoppingListEvent {
  final String shoppingListId; // ID of the shopping list whose details are being loaded

  LoadShoppingListDetail(this.shoppingListId);
}

class AddShoppingList extends ShoppingListEvent {
  final String name; // Name of the shopping list
  final String? description;

  AddShoppingList({
    required this.name,
    this.description,
  });
}

class CreateShoppingListItem extends ShoppingListEvent {
  final ShoppingListItem shoppingListItem;

  CreateShoppingListItem(this.shoppingListItem);
}


class AddItemToShoppingList extends ShoppingListEvent {
  final String shoppingListId; // The ID of the shopping list to which items are added
  final ShoppingListItem shoppingListItem; // The item to be added to the shopping list

  AddItemToShoppingList(this.shoppingListId, this.shoppingListItem);
}

class UpdateItemInShoppingList extends ShoppingListEvent {
  final String shoppingListId; // The ID of the shopping list
  final ShoppingListItem shoppingListItem; // The item to be updated

  UpdateItemInShoppingList(this.shoppingListId, this.shoppingListItem);
}

class RemoveItemFromShoppingList extends ShoppingListEvent {
  final String shoppingListId; // The ID of the shopping list
  final ShoppingListItem shoppingListItem; // The item to be removed from the shopping list

  RemoveItemFromShoppingList(this.shoppingListId, this.shoppingListItem);
}

class MarkItemBought extends ShoppingListEvent {
  final String shoppingListId; // The ID of the shopping list
  final String shoppingListItemId; // The ID of the shopping list item

  MarkItemBought(this.shoppingListId, this.shoppingListItemId);
}

class DeleteShoppingList extends ShoppingListEvent {
  final String shoppingListId; // The ID of the shopping list to delete

  DeleteShoppingList(this.shoppingListId);
}

class UpdateShoppingList extends ShoppingListEvent {
  final String id; // The ID of the shopping list
  final String name; // The new name of the shopping list
  final String? description; // The new description of the shopping list

  UpdateShoppingList({
    required this.id,
    required this.name,
    this.description,
  });
}
