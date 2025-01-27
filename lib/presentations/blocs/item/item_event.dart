part of 'item_bloc.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object> get props => [];
}

class LoadItemPage extends ItemEvent {}

class AddItem extends ItemEvent {
  final Item itemData;

  const AddItem(this.itemData);

  @override
  List<Object> get props => [itemData];
}

class EditItem extends ItemEvent {
  final String itemId;
  final Item itemData;

  const EditItem(this.itemId, this.itemData);

  @override
  List<Object> get props => [itemId, itemData];
}

class AddCategory extends ItemEvent {
  final String categoryName;

  const AddCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

// Edit Category
class EditCategory extends ItemEvent {
  final String categoryId;
  final String categoryName;

  const EditCategory(this.categoryId, this.categoryName);

  @override
  List<Object> get props => [categoryId, categoryName];
}

// Delete Category
class DeleteCategory extends ItemEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class AddLocation extends ItemEvent {
  final String name;

  const AddLocation(this.name);

  @override
  List<Object> get props => [name];
}

// Edit Location
class EditLocation extends ItemEvent {
  final String locationId;
  final String name;

  const EditLocation(this.locationId, this.name);

  @override
  List<Object> get props => [locationId, name];
}

// Delete Location
class DeleteLocation extends ItemEvent {
  final String locationId;

  const DeleteLocation(this.locationId);

  @override
  List<Object> get props => [locationId];
}

class AddSublocation extends ItemEvent {
  final String locationId;
  final String name;

  const AddSublocation(this.locationId, this.name);

  @override
  List<Object> get props => [locationId, name];
}

// Edit Sublocation
class EditSublocation extends ItemEvent {
  final String sublocationId;
  final String name;

  const EditSublocation(this.sublocationId, this.name);

  @override
  List<Object> get props => [sublocationId, name];
}

// Delete Sublocation
class DeleteSublocation extends ItemEvent {
  final String sublocationId;

  const DeleteSublocation(this.sublocationId);

  @override
  List<Object> get props => [sublocationId];
}
