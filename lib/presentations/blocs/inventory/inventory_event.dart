part of 'inventory_bloc.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final String name;
  final String? description;
  final String? categoryId;
  final int quantity;
  final Timestamp? regDate;
  final Timestamp? expDate;
  final String? locationId;
  final String? sublocationId;
  final String accessId;

  const AddInventoryItem({
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    this.regDate,
    this.expDate,
    this.locationId,
    this.sublocationId,
    required this.accessId,
  });
}

class EditInventoryItem extends InventoryEvent {
  final String? itemId;
  final String? id;
  final String name;
  final String? description;
  final String? categoryId;
  final int quantity;
  final Timestamp? regDate;
  final Timestamp? expDate;
  final String? locationId;
  final String? sublocationId;
  final String accessId;

  const EditInventoryItem({
    this.itemId,
    this.id,
    required this.name,
    this.description,
    this.categoryId,
    required this.quantity,
    this.regDate,
    this.expDate,
    this.locationId,
    this.sublocationId,
    required this.accessId,
  });
}

class DeleteInventoryItem extends InventoryEvent {
  final String inventoryItemId;

  const DeleteInventoryItem(this.inventoryItemId);
}

class ConnectToAccessId extends InventoryEvent {
  final String accessId;

  const ConnectToAccessId(this.accessId);

  @override
  List<Object> get props => [accessId];
}

class AddAccessId extends InventoryEvent {
  final String name;

  const AddAccessId(this.name);

  @override
  List<Object> get props => [name];
}

class EditAccessId extends InventoryEvent {
  final String name;

  const EditAccessId(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteAccessId extends InventoryEvent {
  final String accessId;

  const DeleteAccessId(this.accessId);

  @override
  List<Object> get props => [accessId];
}

class AddCategory extends InventoryEvent {
  final String categoryName;
  final String accessId;

  const AddCategory(this.categoryName, this.accessId);

  @override
  List<Object> get props => [categoryName];
}

class EditCategory extends InventoryEvent {
  final String categoryId;
  final String categoryName;
  final String accessId;

  const EditCategory(this.categoryId, this.categoryName, this.accessId);

  @override
  List<Object> get props => [categoryId, categoryName];
}

class DeleteCategory extends InventoryEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class AddLocation extends InventoryEvent {
  final String name;
  final String accessId;

  const AddLocation(this.name, this.accessId);

  @override
  List<Object> get props => [name];
}

class EditLocation extends InventoryEvent {
  final String locationId;
  final String name;
  final String accessId;

  const EditLocation(this.locationId, this.name, this.accessId);

  @override
  List<Object> get props => [locationId, name];
}

class DeleteLocation extends InventoryEvent {
  final String locationId;

  const DeleteLocation(this.locationId);

  @override
  List<Object> get props => [locationId];
}

class AddSublocation extends InventoryEvent {
  final String locationId;
  final String name;
  final String accessId;

  const AddSublocation(this.locationId, this.name, this.accessId);

  @override
  List<Object> get props => [locationId, name];
}

class EditSublocation extends InventoryEvent {
  final String sublocationId;
  final String name;
  final String accessId;

  const EditSublocation(this.sublocationId, this.name, this.accessId);

  @override
  List<Object> get props => [sublocationId, name];
}

class DeleteSublocation extends InventoryEvent {
  final String sublocationId;

  const DeleteSublocation(this.sublocationId);

  @override
  List<Object> get props => [sublocationId];
}
