import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/item/item_bloc.dart';
import 'package:kokiku/presentations/widgets/category_dropdown.dart';
import 'package:kokiku/presentations/widgets/location_dropdown.dart';
import 'package:kokiku/presentations/widgets/sublocation_dropdown.dart';

class AddEditItemPage extends StatefulWidget {
  final Item? item;
  const AddEditItemPage({this.item, super.key});

  @override
  State<AddEditItemPage> createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController regDateController = TextEditingController();
  final TextEditingController expDateController = TextEditingController();
  Location? selectedLocation;
  Sublocation? selectedSublocation;
  ItemCategory? selectedCategory;
  bool isAddMode = false;

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(LoadItemPage());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: BlocListener<ItemBloc, ItemState>(
              listener: (context, state) {
                if (state is ItemError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: BlocBuilder<ItemBloc, ItemState>(
                builder: (context, state) {
                  if (state is ItemLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (state is ItemLoaded) {
                    if (widget.item != null) {
                      nameController.text = widget.item!.name;
                      quantityController.text = widget.item!.quantity.toString();
                      descriptionController.text = widget.item!.description ?? '';
                      regDateController.text = widget.item!.regDate ?? '';
                      expDateController.text = widget.item!.expDate ?? '';
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategoryDropdown(
                              categories: state.categories,
                              selectedCategory: selectedCategory,
                              onChanged: (value) {
                                if (value?.id == 'add') {
                                  _showAddCategoryModal(context);
                                } else {
                                  setState(() => selectedCategory = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Name Text Field
                            _buildTextField('Name', nameController, 'Enter a name'),
                            const SizedBox(height: 16),

                            LocationDropdown(
                              locations: state.locations,
                              selectedLocation: selectedLocation,
                              onChanged: (value) {
                                if (value!.id == 'add') {
                                  _showAddLocationModal(context);
                                } else {
                                  setState(() => selectedLocation = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            SublocationDropdown(
                              sublocations: state.sublocations,
                              selectedLocation: selectedLocation,
                              selectedSublocation: selectedSublocation,
                              onChanged: (value) {
                                if (value!.id == 'add') {
                                  _showAddSublocationModal(context, selectedLocation!.id);
                                } else {
                                  setState(() => selectedSublocation = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Quantity Row
                            _buildQuantityRow(),
                            const SizedBox(height: 16),

                            // Registration Date
                            _buildDatePicker('Registration Date', regDateController, 'Select a registration date'),
                            const SizedBox(height: 16),

                            // Expiry Date
                            _buildDatePicker('Expiry Date', expDateController, 'Select an expiry date'),
                            const SizedBox(height: 16),

                            // Description
                            _buildTextField('Description', descriptionController, 'Fill a description i.e. "1L of Milk"'),
                            const SizedBox(height: 16),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _submitForm(widget.item);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  widget.item == null ? 'Add Item' : 'Save Changes',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(child: Text('Error loading categories, locations, or sublocations'));
                },
              ),
            ),
          ),
          isAddMode ? InkWell(
            onTap: () {
              setState(() {
                isAddMode = false;
                Navigator.pop(context);
              });
            },
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ) : Container()
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? validationMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: validationMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            final currentQuantity = int.tryParse(quantityController.text) ?? 0;
            if (currentQuantity > 0) {
              setState(() {
                quantityController.text = (currentQuantity - 1).toString();
              });
            }
          },
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: TextField(
            controller: quantityController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Quantity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final currentQuantity = int.tryParse(quantityController.text) ?? 0;
            setState(() {
              quantityController.text = (currentQuantity + 1).toString();
            });
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller, String validationMessage) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          setState(() {
            controller.text = DateFormat('dd MMMM yyyy').format(selectedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: validationMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: Icon(Icons.calendar_today)
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm(Item? item) {
    if (formKey.currentState!.validate()) {
      final itemData = Item(
        id: item == null ? '' : item.id,
        name: nameController.text,
        category: selectedCategory!.name,
        location: selectedLocation!.name,
        sublocation: selectedSublocation!.name,
        description: descriptionController.text,
        quantity: int.parse(quantityController.text),
        regDate: regDateController.text,
        expDate: expDateController.text,
      );

      if (item == null) {
        context.read<ItemBloc>().add(AddItem(itemData));
      } else {
        context.read<ItemBloc>().add(EditItem(itemData.id, itemData)); // Update existing item
      }

      Navigator.pop(context);
    }
  }

  void _showAddCategoryModal(BuildContext context) {
    final controller = TextEditingController();
    setState(() {
      isAddMode = true;
    });
    showBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create Category'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ItemBloc>().add(AddCategory(controller.text.trim()));
                  setState(() {
                    isAddMode = false;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationModal(BuildContext context) {
    final controller = TextEditingController();
    setState(() {
      isAddMode = true;
    });
    showBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create Location'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter location name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ItemBloc>().add(AddLocation(controller.text.trim()));
                  setState(() {
                    isAddMode = false;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSublocationModal(BuildContext context, String locationId) {
    final controller = TextEditingController();
    setState(() {
      isAddMode = true;
    });
    showBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create Sublocation'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter sublocation name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ItemBloc>().add(AddSublocation(locationId, controller.text.trim()));
                  setState(() {
                    isAddMode = false;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
