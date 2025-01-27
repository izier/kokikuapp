part of 'item_bloc.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemSuccess extends ItemState {}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object> get props => [message];
}

class ItemLoaded extends ItemState {
  final List<ItemCategory> categories;
  final List<Location> locations;
  final List<Sublocation> sublocations;

  const ItemLoaded({
    required this.categories,
    required this.locations,
    required this.sublocations,
  });

  @override
  List<Object> get props => [
    categories,
    locations,
    sublocations,
  ];
}