import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/pages/shopping_list/add_new_shopping_list_item_page.dart';

class AddShoppingListItemPage extends StatefulWidget {
  final String shoppingListId;

  const AddShoppingListItemPage({super.key, required this.shoppingListId});

  @override
  State<AddShoppingListItemPage> createState() => _AddShoppingListItemPageState();
}

class _AddShoppingListItemPageState extends State<AddShoppingListItemPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShoppingListBloc>().add(LoadShoppingListDetail(widget.shoppingListId));
  }

  void _addItem() {
    // Navigate to a page or show a dialog to add a new shopping list item
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => AddNewShoppingListItemPage(shoppingListId: widget.shoppingListId))
    );
  }

  void _submit() {
    // Submit all selected items with quantity adjustments
    // Handle logic to save or submit data as necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Shopping List Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<ShoppingListBloc, ShoppingListState>(
                builder: (context, state) {
                  if (state is ShoppingListLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ShoppingListDetailLoaded) {
                    return ListView.builder(
                      itemCount: state.shoppingListItems.length,
                      itemBuilder: (context, index) {
                        final item = state.shoppingListItems[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(
                            value: item.isBought,
                            onChanged: (bool? value) {
                              context.read<ShoppingListBloc>().add(MarkItemBought(
                                widget.shoppingListId,
                                item.id,
                              ));
                            },
                          ),
                          title: Text(item.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {

                                },
                              ),
                              Text(item.quantity.toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {

                                },
                              ),
                            ],
                          ),
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
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  side: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1,
                  ),
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Add New Item'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
