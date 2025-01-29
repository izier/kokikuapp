import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final List<ItemCategory>? categories;
  final List<Location>? locations;
  final List<Sublocation>? sublocations;
  const AddEditItemPage({
    this.item,
    this.categories,
    this.locations,
    this.sublocations,
    super.key
  });

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
    quantityController.text = '0';
    if (widget.item != null) {
      nameController.text = widget.item!.name;
      quantityController.text = widget.item!.quantity.toString();
      descriptionController.text = widget.item!.description ?? '';
      regDateController.text = widget.item!.regDate.toString() ?? '';
      expDateController.text = widget.item!.expDate.toString() ?? '';
      final selectedCategories = widget.categories!.where((category) => category.id == widget.item!.categoryId);
      final selectedLocations = widget.locations!.where((location) => location.id == widget.item!.locationId);
      final selectedSublocations = widget.sublocations!.where((sublocation) => sublocation.id == widget.item!.sublocationId);
      if (selectedCategories.isNotEmpty) {
        selectedCategory = selectedCategories.first;
      }
      if (selectedLocations.isNotEmpty) {
        selectedLocation = selectedLocations.first;
      }
      if (selectedSublocations.isNotEmpty) {
        selectedSublocation = selectedSublocations.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        actions: [
          widget.item != null ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(),
          ) : Container(),
        ],
      ),
      body: SafeArea(
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
                        _buildDatePicker(label: 'Registration Date', controller: regDateController, validationMessage: 'Select a registration date'),
                        const SizedBox(height: 16),

                        // Expiry Date
                        _buildDatePicker(label: 'Expiry Date', controller: expDateController, validationMessage: 'Select an expiry date'),
                        const SizedBox(height: 16),

                        // Description
                        _buildTextField('Description', descriptionController, null),
                        const SizedBox(height: 16),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final user = FirebaseAuth.instance.currentUser;
                                _submitForm(Item(
                                  id: widget.item?.id ?? '',
                                  name: nameController.text,
                                  categoryId: selectedCategory != null ? selectedCategory!.id : '',
                                  locationId: selectedLocation != null ? selectedLocation!.id : '',
                                  sublocationId: selectedSublocation != null ? selectedSublocation!.id : '',
                                  description: descriptionController.text,
                                  quantity: int.parse(quantityController.text),
                                  regDate: parseDateToTimestamp(regDateController.text),
                                  expDate: parseDateToTimestamp(expDateController.text),
                                  userId: user!.uid,
                                ));
                              }
                            },
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
              return Container();
            },
          ),
        ),
      ),
    );
  }

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

  Widget _buildDatePicker({
    required String label,
    required TextEditingController controller,
    required String validationMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true, // Prevent manual input
          decoration: InputDecoration(
            hintText: validationMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  controller.text = DateFormat('dd MMMM yyyy').format(selectedDate);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm(Item item) {
    if (formKey.currentState!.validate()) {
      // if (selectedCategory == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please select a category.')),
      //   );
      //   return;
      // }
      // if (selectedLocation == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please select a location.')),
      //   );
      //   return;
      // }
      // if (selectedSublocation == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please select a sublocation.')),
      //   );
      //   return;
      // }

      // Submit the item
      if (widget.item == null) {
        context.read<ItemBloc>().add(AddItem(item));
      } else {
        context.read<ItemBloc>().add(EditItem(item.id, item));
      }

      Navigator.pop(context);
    }
  }

  void _showAddCategoryModal(BuildContext context) {
    final controller = TextEditingController();

    // Show the modal bottom sheet
    showBottomSheet(
      context: context,
      builder: (_) => Container(
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  context.read<ItemBloc>().add(AddCategory(controller.text.trim()));
                  Navigator.pop(context); // Close the bottom sheet after adding
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

    showBottomSheet(
      context: context,
      builder: (_) => Container(
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  context.read<ItemBloc>().add(AddLocation(controller.text.trim()));
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
    showBottomSheet(
      context: context,
      builder: (_) => Container(
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  context.read<ItemBloc>().add(AddSublocation(locationId, controller.text.trim()));
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

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              context.read<ItemBloc>().add(DeleteItem(widget.item!.id));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Convert the controller text to a Timestamp
  Timestamp? parseDateToTimestamp(String dateText) {
    if (dateText.isEmpty) return null; // Handle empty input

    try {
      DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(dateText);
      return Timestamp.fromDate(parsedDate);
    } catch (e) {
      log('Error parsing date: $e');
      return null;
    }
  }
}