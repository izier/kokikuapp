part of 'shopping_list_bloc.dart';

abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();

  @override
  List<Object> get props => [];
}

class LoadShoppingLists extends ShoppingListEvent {
  const LoadShoppingLists();
}

class LoadShoppingListDetail extends ShoppingListEvent {
  final String? shoppingListId;

  const LoadShoppingListDetail({this.shoppingListId});

  @override
  List<Object> get props => [shoppingListId ?? ''];
}

class AddShoppingList extends ShoppingListEvent {
  final String accessId;
  final String name;
  final String? description;
  final List<ShoppingListItem> shoppingListItems;

  const AddShoppingList({
    required this.accessId,
    required this.name,
    this.description,
    required this.shoppingListItems,
  });

  @override
  List<Object> get props => [accessId, name, description ?? '', shoppingListItems];
}

class EditShoppingList extends ShoppingListEvent {
  final String id;
  final String accessId;
  final String name;
  final String? description;
  final List<ShoppingListItem> shoppingListItems;

  const EditShoppingList({
    required this.id,
    required this.accessId,
    required this.name,
    this.description,
    required this.shoppingListItems,
  });

  @override
  List<Object> get props => [id, accessId, name, description ?? '', shoppingListItems];
}

class DeleteShoppingList extends ShoppingListEvent {
  final String shoppingListId;

  const DeleteShoppingList({required this.shoppingListId});

  @override
  List<Object> get props => [shoppingListId];
}

class FinishShoppingList extends ShoppingListEvent {
  final ShoppingList shoppingList;

  const FinishShoppingList({required this.shoppingList});

  @override
  List<Object> get props => [shoppingList];
}

class CreateItem extends ShoppingListEvent {
  final String name;
  final String accessId;

  const CreateItem({
    required this.name,
    required this.accessId,
  });

  @override
  List<Object> get props => [
    name,
    accessId,
  ];
}

class CreateShoppingListItem extends ShoppingListEvent {
  final String shoppingListId;
  final String name;
  final String? description;
  final String? categoryId;
  final int quantity;
  final String accessId;

  const CreateShoppingListItem({
    required this.shoppingListId,
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    required this.accessId,
  });

  @override
  List<Object> get props => [
    shoppingListId,
    name,
    description ?? '',
    categoryId ?? '',
    quantity,
    accessId,
  ];
}

class EditShoppingListItem extends ShoppingListEvent {
  final String shoppingListId;
  final ShoppingListItem item;

  const EditShoppingListItem({required this.shoppingListId, required this.item});

  @override
  List<Object> get props => [shoppingListId, item];
}

class DeleteShoppingListItem extends ShoppingListEvent {
  final String shoppingListId;
  final String itemId;

  const DeleteShoppingListItem({required this.shoppingListId, required this.itemId});

  @override
  List<Object> get props => [shoppingListId, itemId];
}

class AddShoppingListItem extends ShoppingListEvent {
  final String shoppingListId;
  final List<Item> items;
  final List<int> quantity;
  final String accessId;

  const AddShoppingListItem({
    required this.shoppingListId,
    required this.items,
    required this.quantity,
    required this.accessId,
  });

  @override
  List<Object> get props => [shoppingListId, items];
}

class RemoveShoppingListItem extends ShoppingListEvent {
  final String shoppingListId;
  final String itemId;

  const RemoveShoppingListItem({required this.shoppingListId, required this.itemId});

  @override
  List<Object> get props => [shoppingListId, itemId];
}

class MarkItemBought extends ShoppingListEvent {
  final String shoppingListId;
  final String itemId;

  const MarkItemBought({required this.shoppingListId, required this.itemId});

  @override
  List<Object> get props => [shoppingListId, itemId];
}
