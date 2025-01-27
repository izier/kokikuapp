import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/presentations/blocs/item/item_bloc.dart';
import 'package:kokiku/presentations/widgets/category_dropdown.dart';
import 'package:kokiku/presentations/widgets/location_dropdown.dart';
import 'package:kokiku/presentations/widgets/sublocation_dropdown.dart';

class AddEditItemPage extends StatefulWidget {
  final String? itemId;

  const AddEditItemPage({this.itemId, super.key});

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
  String? selectedSublocation;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load categories and saving places when the page is initialized
    context.read<ItemBloc>().add(LoadItemPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.itemId == null ? 'Add Item' : 'Edit Item')),
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemLoaded) {
            // You can further customize behavior here after loading categories and saving places
          } else if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is ItemLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Dropdown
                        CategoryDropdown(
                          categories: state.categories,
                          selectedCategory: selectedCategory,
                          onChanged: (value) {
                            if (value == 'add') {
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

                        // Location Dropdown
                        LocationDropdown(
                          locations: state.locations,
                          selectedLocation: selectedLocation,
                          onChanged: (value) {
                            if (value == null) {
                              _showAddLocationModal(context);
                            } else {
                              setState(() => selectedLocation = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sublocation Dropdown
                        SublocationDropdown(
                          sublocations: state.sublocations,
                          selectedLocation: selectedLocation,
                          selectedSublocation: selectedSublocation,
                          onChanged: (value) {
                            if (value == 'add') {
                              _showAddSublocationModal(
                                  context, selectedLocation!.id);
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
                        _buildDatePicker(
                            'Registration Date', regDateController, 'Select a registration date'),
                        const SizedBox(height: 16),

                        // Expiry Date
                        _buildDatePicker(
                            'Expiry Date', expDateController, 'Select an expiry date'),
                        const SizedBox(height: 16),

                        // Description
                        _buildTextField('Description', descriptionController, null),
                        const SizedBox(height: 16),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(
                              widget.itemId == null ? 'Add Item' : 'Save Changes',
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
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String? validationMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: validationMessage == null
              ? null
              : (value) => value == null || value.isEmpty ? validationMessage : null,
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
          child: TextFormField(
            controller: quantityController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
            value == null || int.tryParse(value) == null ? 'Enter a valid number' : null,
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
            controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? validationMessage : null,
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final itemData = Item(
        id: widget.itemId ?? '',
        name: nameController.text,
        category: selectedCategory!,
        location: selectedLocation!.name,
        sublocation: selectedSublocation,
        description: descriptionController.text,
        quantity: int.parse(quantityController.text),
        regDate: regDateController.text,
        expDate: expDateController.text,
      );
      context.read<ItemBloc>().add(AddItem(itemData));
      Navigator.pop(context);
    }
  }

  void _showAddCategoryModal(BuildContext context) {
    final controller = TextEditingController();

    showBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Category', style: TextStyle(fontSize: 18)),
              TextField(controller: controller, decoration: InputDecoration(labelText: 'Name')),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Add the new category through the ItemBloc
                  context.read<ItemBloc>().add(AddCategory(controller.text.trim()));
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLocationModal(BuildContext context) {
    final controller = TextEditingController();

    showBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Location', style: TextStyle(fontSize: 18)),
              TextField(controller: controller, decoration: InputDecoration(labelText: 'Name')),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ItemBloc>().add(AddLocation(controller.text.trim()));
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSublocationModal(BuildContext context, String locationId) {
    final controller = TextEditingController();

    showBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Sublocation', style: TextStyle(fontSize: 18)),
              TextField(controller: controller, decoration: InputDecoration(labelText: 'Name')),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ItemBloc>().add(AddSublocation(locationId, controller.text.trim()));
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
