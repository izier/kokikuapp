import 'package:get_it/get_it.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/blocs/item/item_bloc.dart';
import 'package:kokiku/presentations/blocs/profile/profile_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerFactory(() => InventoryBloc());
  getIt.registerFactory(() => ProfileBloc());
  getIt.registerFactory(() => ItemBloc());
}
