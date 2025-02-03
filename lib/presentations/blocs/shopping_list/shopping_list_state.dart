part of 'shopping_list_bloc.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();

  @override
  List<Object> get props => [];
}

class ShoppingListInitial extends ShoppingListState {
  const ShoppingListInitial();
}

class ShoppingListLoading extends ShoppingListState {
  const ShoppingListLoading();
}

class ShoppingListNoInternet extends ShoppingListState {
  const ShoppingListNoInternet();
}

class ShoppingListLoaded extends ShoppingListState {
  final List<AccessId> accessIds;
  final List<ShoppingList> shoppingLists;

  const ShoppingListLoaded({required this.accessIds, required this.shoppingLists});

  @override
  List<Object> get props => [accessIds, shoppingLists];
}

class ShoppingListError extends ShoppingListState {
  final String message;

  const ShoppingListError({required this.message});

  @override
  List<Object> get props => [message];
}

class ShoppingListNoAccessIds extends ShoppingListState {
  const ShoppingListNoAccessIds();
}

class ShoppingListDetailLoaded extends ShoppingListState {
  final List<AccessId> accessIds;
  final List<ShoppingListItem> shoppingListItems;
  final List<Item> items;
  final String shoppingListId;

  const ShoppingListDetailLoaded({
    required this.accessIds,
    required this.shoppingListItems,
    required this.items,
    required this.shoppingListId,
  });

  @override
  List<Object> get props => [accessIds, shoppingListItems, shoppingListId];
}

class ShoppingListDetailLoadError extends ShoppingListState {
  final String message;

  const ShoppingListDetailLoadError({required this.message});

  @override
  List<Object> get props => [message];
}

class AddShoppingListSuccess extends ShoppingListState {
  const AddShoppingListSuccess();
}

class AddShoppingListError extends ShoppingListState {
  final String message;

  const AddShoppingListError({required this.message});

  @override
  List<Object> get props => [message];
}

class EditShoppingListSuccess extends ShoppingListState {
  const EditShoppingListSuccess();
}

class EditShoppingListError extends ShoppingListState {
  final String message;

  const EditShoppingListError({required this.message});

  @override
  List<Object> get props => [message];
}

class DeleteShoppingListSuccess extends ShoppingListState {
  const DeleteShoppingListSuccess();
}

class DeleteShoppingListError extends ShoppingListState {
  final String message;

  const DeleteShoppingListError({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateShoppingListItemSuccess extends ShoppingListState {
  const CreateShoppingListItemSuccess();
}

class CreateShoppingListItemError extends ShoppingListState {
  final String message;

  const CreateShoppingListItemError({required this.message});

  @override
  List<Object> get props => [message];
}

class EditShoppingListItemSuccess extends ShoppingListState {
  const EditShoppingListItemSuccess();
}

class EditShoppingListItemError extends ShoppingListState {
  final String message;

  const EditShoppingListItemError({required this.message});

  @override
  List<Object> get props => [message];
}

class DeleteShoppingListItemSuccess extends ShoppingListState {
  const DeleteShoppingListItemSuccess();
}

class DeleteShoppingListItemError extends ShoppingListState {
  final String message;

  const DeleteShoppingListItemError({required this.message});

  @override
  List<Object> get props => [message];
}

class AddShoppingListItemSuccess extends ShoppingListState {
  const AddShoppingListItemSuccess();
}

class AddShoppingListItemError extends ShoppingListState {
  final String message;

  const AddShoppingListItemError({required this.message});

  @override
  List<Object> get props => [message];
}

class RemoveShoppingListItemSuccess extends ShoppingListState {
  const RemoveShoppingListItemSuccess();
}

class RemoveShoppingListItemError extends ShoppingListState {
  final String message;

  const RemoveShoppingListItemError({required this.message});

  @override
  List<Object> get props => [message];
}

class MarkItemBoughtSuccess extends ShoppingListState {
  const MarkItemBoughtSuccess();
}

class MarkItemBoughtError extends ShoppingListState {
  final String message;

  const MarkItemBoughtError({required this.message});

  @override
  List<Object> get props => [message];
}
