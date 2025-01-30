part of 'inventory_bloc.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryNoInternet extends InventoryState {}

class InventoryNoAccessIds extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> inventoryItems;
  final List<AccessId> accessIds;
  final List<ItemCategory> categories;
  final List<Location> locations;
  final List<Sublocation> sublocations;

  const InventoryLoaded({
    required this.inventoryItems,
    required this.accessIds,
    required this.categories,
    required this.locations,
    required this.sublocations,
  });

  @override
  List<Object> get props => [
    inventoryItems,
    categories,
    locations,
    sublocations,
  ];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object> get props => [message];
}

class AddInventoryItemSuccess extends InventoryState {}

class AddInventoryItemError extends InventoryState {
  final String message;

  const AddInventoryItemError(this.message);

  @override
  List<Object> get props => [message];
}

class EditInventoryItemSuccess extends InventoryState {}

class EditInventoryItemError extends InventoryState {
  final String message;

  const EditInventoryItemError(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteInventoryItemSuccess extends InventoryState {}

class DeleteInventoryItemError extends InventoryState {
  final String message;

  const DeleteInventoryItemError(this.message);

  @override
  List<Object> get props => [message];
}

class AddAccessIdSuccess extends InventoryState {}

class AddAccessIdError extends InventoryState {
  final String message;

  const AddAccessIdError(this.message);

  @override
  List<Object> get props => [message];
}


class AddCategoriesSuccess extends InventoryState {}

class AddCategoriesError extends InventoryState {
  final String message;

  const AddCategoriesError(this.message);

  @override
  List<Object> get props => [message];
}

class EditCategoriesSuccess extends InventoryState {}

class EditCategoriesError extends InventoryState {
  final String message;

  const EditCategoriesError(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteCategoriesSuccess extends InventoryState {}

class DeleteCategoriesError extends InventoryState {
  final String message;

  const DeleteCategoriesError(this.message);

  @override
  List<Object> get props => [message];
}

class AddLocationSuccess extends InventoryState {}

class AddLocationError extends InventoryState {
  final String message;

  const AddLocationError(this.message);

  @override
  List<Object> get props => [message];
}

class EditLocationSuccess extends InventoryState {}

class EditLocationError extends InventoryState {
  final String message;

  const EditLocationError(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteLocationSuccess extends InventoryState {}

class DeleteLocationError extends InventoryState {
  final String message;

  const DeleteLocationError(this.message);

  @override
  List<Object> get props => [message];
}

class AddSubLocationSuccess extends InventoryState {}

class AddSubLocationError extends InventoryState {
  final String message;

  const AddSubLocationError(this.message);

  @override
  List<Object> get props => [message];
}
class EditSubLocationSuccess extends InventoryState {}

class EditSubLocationError extends InventoryState {
  final String message;

  const EditSubLocationError(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteSubLocationSuccess extends InventoryState {}

class DeleteSubLocationError extends InventoryState {
  final String message;

  const DeleteSubLocationError(this.message);

  @override
  List<Object> get props => [message];
}