import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/pages/shopping_list/add_shopping_list_item_page.dart';

class ShoppingListDetailPage extends StatefulWidget {
  final String shoppingListId;
  final String shoppingListName;
  final String? shoppingListDescription; // Optional description

  const ShoppingListDetailPage({
    super.key,
    required this.shoppingListId,
    required this.shoppingListName,
    this.shoppingListDescription,
  });

  @override
  State<ShoppingListDetailPage> createState() => _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState extends State<ShoppingListDetailPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.shoppingListName);
    descriptionController = TextEditingController(text: widget.shoppingListDescription ?? '');

    context.read<ShoppingListBloc>().add(LoadShoppingListDetail(shoppingListId: widget.shoppingListId));
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // if (nameController.text.isNotEmpty) {
    //   context.read<ShoppingListBloc>().add(EditShoppingList(
    //     id: widget.shoppingListId,
    //     name: nameController.text,
    //     description: descriptionController.text,
    //   ));
    // }
  }

  // Helper method for building text fields
  Widget _buildTextField(String label, TextEditingController controller, String? validationMessage, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validationMessage;
            }
            if (isNumber && int.tryParse(value) == null) {
              return 'Please enter a valid number.';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: validationMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping List Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              'Shopping List Name',
              nameController,
              'Enter shopping list name',
            ),
            SizedBox(height: 16),
            _buildTextField(
              'Description',
              descriptionController,
              'Enter description (optional)',
              isNumber: false,
            ),
            SizedBox(height: 16),
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
                          title: Text(item.name),
                          subtitle: Text(item.isBought ? 'Bought' : 'Not bought'),
                          onTap: () {
                            context.read<ShoppingListBloc>().add(MarkItemBought(
                              shoppingListId: widget.shoppingListId,
                              itemId: item.id!,
                            ));
                          },
                        );
                      },
                    );
                  } else if (state is ShoppingListError) {
                    return Center(child: Text(state.message));
                  } else {
                    return Center(child: Text('No items found.'));
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddShoppingListItemPage(shoppingListId: widget.shoppingListId)
                    )
                  );
                },
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
                child: Text('Add Item'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
