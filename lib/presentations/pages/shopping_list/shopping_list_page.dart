import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/pages/shopping_list/shopping_list_detail_page.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ShoppingListBloc>().add(LoadShoppingLists());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Lists'),
      ),
      body: BlocBuilder<ShoppingListBloc, ShoppingListState>(
        builder: (context, state) {
          if (state is ShoppingListLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ShoppingListLoaded) {
            return ListView.builder(
              itemCount: state.shoppingLists.length,
              itemBuilder: (context, index) {
                final shoppingList = state.shoppingLists[index];
                return ListTile(
                  title: Text(shoppingList.name),
                  onTap: () {
                    // Navigate to the shopping list detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShoppingListDetailPage(
                          shoppingListId: shoppingList.id!,
                          shoppingListName: shoppingList.name,
                          shoppingListDescription: shoppingList.description,
                        ),
                      ),
                    ).whenComplete(() => _loadData());
                  },
                );
              },
            );
          } else if (state is ShoppingListError) {
            return Center(child: Text(state.message));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
