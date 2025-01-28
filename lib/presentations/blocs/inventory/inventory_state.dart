part of 'inventory_bloc.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Item> items;
  final List<ItemCategory> categories;
  final List<Location> locations;
  final List<Sublocation> sublocations;
  InventoryLoaded(this.items, this.categories, this.locations, this.sublocations);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}
