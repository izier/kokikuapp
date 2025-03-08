import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/inventory_item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/widgets/access_id_dropdown.dart';
import 'package:kokiku/presentations/widgets/category_dropdown.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';
import 'package:kokiku/presentations/widgets/location_dropdown.dart';
import 'package:kokiku/presentations/widgets/sublocation_dropdown.dart';

class InventoryAddEditItemPage extends StatefulWidget {
  final InventoryItem? item;
  final List<AccessId>? accessIds;
  final List<ItemCategory>? categories;
  final List<Location>? locations;
  final List<Sublocation>? sublocations;

  const InventoryAddEditItemPage({
    this.item,
    this.accessIds,
    this.categories,
    this.locations,
    this.sublocations,
    super.key
  });

  @override
  State<InventoryAddEditItemPage> createState() => _InventoryAddEditItemPageState();
}

class _InventoryAddEditItemPageState extends State<InventoryAddEditItemPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController regDateController = TextEditingController();
  final TextEditingController expDateController = TextEditingController();
  AccessId? selectedAccessId;
  Location? selectedLocation;
  Sublocation? selectedSublocation;
  ItemCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(LoadInventory());
    quantityController.text = '0';
    if (widget.item != null) {
      nameController.text = widget.item!.name;
      quantityController.text = widget.item!.quantity.toString();
      descriptionController.text = widget.item!.description ?? '';
      widget.item!.regDate != null ? setDateControllerText(regDateController, widget.item!.regDate) : regDateController.text = '';
      widget.item!.expDate != null ? setDateControllerText(expDateController, widget.item!.regDate) : expDateController.text = '';
      final selectedAccessIds = widget.accessIds!.where((accessId) => accessId.id == widget.item!.accessId);
      final selectedCategories = widget.categories!.where((category) => category.id == widget.item!.categoryId);
      final selectedLocations = widget.locations!.where((location) => location.id == widget.item!.locationId);
      final selectedSublocations = widget.sublocations!.where((sublocation) => sublocation.id == widget.item!.sublocationId);
      if  (selectedAccessIds.isNotEmpty) {
        selectedAccessId = selectedAccessIds.first;
      }
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
    final localization = LocalizationService.of(context)!;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(widget.item == null
            ? localization.translate('add_item')
            : localization.translate('edit_item')),
        actions: [
          if (widget.item != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(),
            ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is InventoryError) {
              showErrorToast(
                  context: context,
                  title: localization.translate('error_occurred'),
                  message: state.message
              );
            }
          },
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is InventoryLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Access ID Dropdown
                        AccessIdDropdown(
                          accessIds: state.accessIds,
                          selectedAccessId: selectedAccessId,
                          onChanged: (value) {
                            setState(() => selectedAccessId = value);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        CategoryDropdown(
                          categories: state.categories,
                          selectedCategory: selectedCategory,
                          selectedAccessId: selectedAccessId,
                          onChanged: (value) {
                            if (value?.id == 'add') {
                              _showAddCategoryModal(context);
                            } else {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                        if (selectedAccessId != null) const SizedBox(height: 16),

                        // Item Name
                        _buildTextField(
                            localization.translate('name'),
                            nameController,
                            localization.translate('enter_name')
                        ),
                        const SizedBox(height: 16),

                        // Location Dropdown
                        LocationDropdown(
                          selectedAccessId: selectedAccessId,
                          locations: state.locations,
                          selectedLocation: selectedLocation,
                          onChanged: (value) {
                            if (value!.id == 'add') {
                              _showAddLocationModal(context);
                            } else {
                              setState(() {
                                selectedLocation = value;
                                selectedSublocation = null;
                              });
                            }
                          },
                        ),
                        if (selectedAccessId != null) const SizedBox(height: 16),

                        // Sublocation Dropdown
                        SublocationDropdown(
                          selectedAccessId: selectedAccessId,
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
                        if (selectedLocation != null) const SizedBox(height: 16),

                        // Quantity
                        _buildQuantityRow(localization),
                        const SizedBox(height: 16),

                        // Registration Date
                        _buildDatePicker(
                            label: localization.translate('registration_date'),
                            controller: regDateController,
                            validationMessage: localization.translate('select_registration_date')
                        ),
                        const SizedBox(height: 16),

                        // Expiry Date
                        _buildDatePicker(
                            label: localization.translate('expiry_date'),
                            controller: expDateController,
                            validationMessage: localization.translate('select_expiry_date')
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildTextField(
                            localization.translate('description'),
                            descriptionController,
                            null
                        ),
                        const SizedBox(height: 16),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(
                              widget.item == null
                                  ? localization.translate('add_item')
                                  : localization.translate('save_changes'),
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
    final localization = LocalizationService.of(context)!;
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
              return localization.translate('invalid_number');
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

  Widget _buildQuantityRow(LocalizationService localization) {
    return Row(
      children: [
        Text(localization.translate('quantity'), style: TextStyle(fontWeight: FontWeight.bold)),
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
          icon: Icon(Icons.remove),
        ),
        Expanded(
          child: TextField(
            controller: quantityController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: localization.translate('quantity'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12),
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
          icon: Icon(Icons.add),
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
          onTap: () async {
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

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      // Submit the item
      if (widget.item == null) {
        context.read<InventoryBloc>().add(AddInventoryItem(
          name: nameController.text,
          categoryId: selectedCategory != null ? selectedCategory!.id : '',
          locationId: selectedLocation != null ? selectedLocation!.id : '',
          sublocationId: selectedSublocation != null ? selectedSublocation!.id : '',
          description: descriptionController.text,
          quantity: int.parse(quantityController.text),
          regDate: parseDateToTimestamp(regDateController.text),
          expDate: parseDateToTimestamp(expDateController.text),
          accessId: selectedAccessId!.id,
        ));
      } else {
        context.read<InventoryBloc>().add(EditInventoryItem(
          id: widget.item?.id ?? '',
          name: nameController.text,
          categoryId: selectedCategory != null ? selectedCategory!.id : '',
          locationId: selectedLocation != null ? selectedLocation!.id : '',
          sublocationId: selectedSublocation != null ? selectedSublocation!.id : '',
          description: descriptionController.text,
          quantity: int.parse(quantityController.text),
          regDate: parseDateToTimestamp(regDateController.text),
          expDate: parseDateToTimestamp(expDateController.text),
          accessId: selectedAccessId!.id,
          itemId: widget.item?.itemId,
        ));
      }

      Navigator.pop(context);
    }
  }

  void _showAddCategoryModal(BuildContext context) {
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
          title: Text(localization.translate('create_category')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: focusNode,
                controller: controller,
                decoration: InputDecoration(
                  label: Text(localization.translate('category_name')),
                  hintText: localization.translate('enter_category_name'),
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
                    context.read<InventoryBloc>().add(AddCategory(
                        controller.text.trim(), selectedAccessId!.id));
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

  void _showAddLocationModal(BuildContext context) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final localization = LocalizationService.of(context)!;

    showDialog(
      context: context,
      builder: (_) {
        Future.delayed(Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
        return AlertDialog(
          title: Text(localization.translate('create_location')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: focusNode,
                controller: controller,
                decoration: InputDecoration(
                  label: Text(localization.translate('location_name')),
                  hintText: localization.translate('enter_location_name'),
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
                    context.read<InventoryBloc>().add(
                        AddLocation(controller.text.trim(), selectedAccessId!.id));
                    Navigator.pop(context);
                  },
                  child: Text(localization.translate('add')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSublocationModal(BuildContext context, String locationId) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final localization = LocalizationService.of(context)!;

    showDialog(
      context: context,
      builder: (_) {
        Future.delayed(Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
        return AlertDialog(
          title: Text(localization.translate('create_sublocation')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: focusNode,
                controller: controller,
                decoration: InputDecoration(
                  label: Text(localization.translate('sublocation_name')),
                  hintText: localization.translate('enter_sublocation_name'),
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
                    context.read<InventoryBloc>().add(
                        AddSublocation(locationId, controller.text.trim(), selectedAccessId!.id));
                    Navigator.pop(context);
                  },
                  child: Text(localization.translate('add')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    final localization = LocalizationService.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('delete_item')),
        content: Text(localization.translate('delete_item_confirmation')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<InventoryBloc>().add(DeleteInventoryItem(widget.item!.id!));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(localization.translate('delete')),
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

  void setDateControllerText(TextEditingController controller, dynamic timestamp) {
    if (timestamp is Timestamp) {
      controller.text = DateFormat('dd MMMM yyyy').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      controller.text = DateFormat('dd MMMM yyyy').format(timestamp);
    } else {
      controller.text = ''; // Handle empty or invalid values
    }
  }
}