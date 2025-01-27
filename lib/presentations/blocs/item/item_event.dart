// item_event.dart
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

class AddLocation extends ItemEvent {
  final String name;

  const AddLocation(this.name);

  @override
  List<Object> get props => [name];
}


class AddSublocation extends ItemEvent {
  final String locationId;
  final String name;

  const AddSublocation(this.locationId, this.name);

  @override
  List<Object> get props => [name];
}