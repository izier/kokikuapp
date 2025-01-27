part of 'inventory_bloc.dart';

abstract class InventoryEvent {}

class LoadInventory extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final Item item;
  AddInventoryItem(this.item);
}

class UpdateInventoryItem extends InventoryEvent {
  final Item item;
  UpdateInventoryItem(this.item);
}

class DeleteInventoryItem extends InventoryEvent {
  final String itemId;
  DeleteInventoryItem(this.itemId);
}
