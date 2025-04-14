import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/shopping_list_item.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/widgets/access_id_dropdown.dart';

class ShoppingListAddEditPage extends StatefulWidget {
  final String? shoppingListId;
  final String? shoppingListName;
  final String? shoppingListDescription;

  const ShoppingListAddEditPage({
    super.key,
    this.shoppingListId,
    this.shoppingListName,
    this.shoppingListDescription,
  });

  @override
  State<ShoppingListAddEditPage> createState() => _ShoppingListAddEditPageState();
}

class _ShoppingListAddEditPageState extends State<ShoppingListAddEditPage> {
  AccessId? selectedAccessId;
  Map<String, ValueNotifier<int>> quantityNotifiers = {};
  Map<String, ShoppingListItem> selectedItems = {};
  String searchQuery = "";

  late TextEditingController nameController = TextEditingController(text: widget.shoppingListName);
  late TextEditingController descriptionController = TextEditingController(text: widget.shoppingListDescription ?? '');
  late TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.shoppingListId != null) {
      context.read<ShoppingListBloc>().add(LoadShoppingListDetail(shoppingListId: widget.shoppingListId!));
    } else {
      context.read<ShoppingListBloc>().add(LoadShoppingListDetail());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    for (var notifier in quantityNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _showCreateItemModal(BuildContext context) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final localization = LocalizationService.of(context)!;

    // Show the bottom sheet
    showDialog(
        context: context,
        builder: (_) {
          Future.delayed(Duration(milliseconds: 100), () {
            focusNode.requestFocus();
          });
          return AlertDialog(
            title: Text(localization.translate('create_item')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  focusNode: focusNode,
                  controller: controller,
                  decoration: InputDecoration(
                    label: Text(localization.translate('item_name')),
                    hintText: localization.translate('enter_item_name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<ShoppingListBloc>().add(CreateItem(
                          accessId: selectedAccessId!.id,
                          name: controller.text.trim()));
                      Navigator.pop(
                          context); // Close the bottom sheet after adding
                    },
                    child: Text(localization.translate('add')),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(widget.shoppingListId == null ? "Create Shopping List" : "Edit Shopping List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ShoppingListBloc, ShoppingListState>(
          builder: (context, state) {
            if (state is ShoppingListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ShoppingListDetailLoaded) {
              final filteredItems = state.items.where((item) =>
                  item.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessIdDropdown(
                    accessIds: state.accessIds,
                    selectedAccessId: selectedAccessId,
                    onChanged: (value) {
                      setState(() => selectedAccessId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Shopping List Name', nameController, 'Enter shopping list name'),
                  const SizedBox(height: 16),
                  _buildTextField('Description', descriptionController, 'Enter description (optional)'),
                  const SizedBox(height: 16),
                  Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            _showCreateItemModal(context);
                          },
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        quantityNotifiers.putIfAbsent(item.id!, () => ValueNotifier<int>(0));
                        quantityNotifiers[item.id]!.addListener(() {
                          final quantity = quantityNotifiers[item.id]!.value;
                          if (quantity > 0) {
                            selectedItems[item.id!] = ShoppingListItem(
                              id: item.id!,
                              name: item.name,
                              quantity: quantity,
                              isBought: false,
                            );
                          } else {
                            selectedItems.remove(item.id!);
                          }
                        });

                        return ListTile(
                          title: Text(item.name),
                          trailing: ValueListenableBuilder<int>(
                            valueListenable: quantityNotifiers[item.id]!,
                            builder: (context, value, child) {
                              final controller = TextEditingController(text: value.toString());

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      if (value > 0) {
                                        quantityNotifiers[item.id]!.value = value - 1;
                                      }
                                    },
                                  ),

                                  SizedBox(
                                    width: 50,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      controller: controller,
                                      onChanged: (text) {
                                        final int? newValue = int.tryParse(text);
                                        if (newValue != null && newValue >= 0) {
                                          quantityNotifiers[item.id]!.value = newValue;
                                        }
                                      },
                                    ),
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      quantityNotifiers[item.id]!.value = value + 1;
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text("Save"),
                  ),
                ],
              );
            } else if (state is ShoppingListError) {
              return Center(child: Text(state.message));
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? validationMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: validationMessage,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    context.read<ShoppingListBloc>().add(AddShoppingList(
      accessId: selectedAccessId!.id,
      name: nameController.text,
      description: descriptionController.text,
      shoppingListItems: selectedItems.values.toList())
    );
  }
}
