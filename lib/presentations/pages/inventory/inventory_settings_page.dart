import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/pages/inventory/qr_scanner_page.dart';
import 'package:kokiku/presentations/widgets/access_id_dropdown.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';
import 'package:kokiku/presentations/widgets/location_dropdown.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InventorySettingsPage extends StatefulWidget {
  const InventorySettingsPage({super.key});

  @override
  State<InventorySettingsPage> createState() => _InventorySettingsPageState();
}

class _InventorySettingsPageState extends State<InventorySettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Location? selectedLocation;

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(LoadInventory());
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!; // Get the localization instance

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(localization.translate('inventory_settings')),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          isScrollable: false,
          dividerColor: Colors.transparent,
          controller: _tabController,
          tabs: [
            Tab(text: localization.translate('access_id')),
            Tab(text: localization.translate('categories')),
            Tab(text: localization.translate('locations')),
            Tab(text: localization.translate('sublocations')),
          ],
        ),
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            showErrorToast(context: context, title: 'An Error Has Occured', message: state.message);
          }
        },
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InventoryLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildAccessIdList(
                    accessIds: state.accessIds,
                    onAdd: () => _showAddModal(accessIds: state.accessIds, context: context, title: localization.translate('add_new_access_id'), isCategory: false, isAccessId: true),
                  ),
                  // Category Section
                  _buildSection(
                    context,
                    title: localization.translate('categories'),
                    items: state.categories,
                    onEdit: (item) => _showEditModal(context, item, localization.translate('edit_category'), isCategory: true),
                    onDelete: (item) => _deleteCategory(context, item),
                    onAdd: () => _showAddModal(accessIds: state.accessIds, context: context, title: localization.translate('add_new_category'), isCategory: true, isAccessId: false),
                  ),
                  // Location Section
                  _buildSection(
                    context,
                    title: localization.translate('locations'),
                    items: state.locations,
                    onEdit: (item) => _showEditModal(context, item, localization.translate('edit_location'), isCategory: false),
                    onDelete: (item) => _deleteLocation(context, item),
                    onAdd: () => _showAddModal(accessIds: state.accessIds, context: context, title: localization.translate('add_new_location'), isCategory: false, isAccessId: false),
                  ),
                  // Sublocation Section
                  _buildSection(
                    context,
                    title: localization.translate('sublocations'),
                    items: state.sublocations,
                    onEdit: (item) => _showEditModal(context, item, localization.translate('edit_sublocation'), isCategory: false),
                    onDelete: (item) => _deleteSublocation(context, item),
                    onAdd: () => _showAddModal(accessIds: state.accessIds, context: context, title: localization.translate('add_new_sublocation'), locations: state.locations, isCategory: false, isAccessId: false),
                  ),
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildAccessIdList({
    required List<AccessId> accessIds,
    required VoidCallback onAdd
  }) {
    final localization = LocalizationService.of(context)!; // Get the localization instance
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          ListView.builder(
            itemCount: accessIds.length,
            itemBuilder: (context, index) {
              final accessId = accessIds[index];
              return Card(
                elevation: 0,
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 16),
                  title: Text(accessId.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code),
                        onPressed: () => _showQrDialog(accessId.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openQRScanner,
                child: Text('${localization.translate('connect')} Access ID'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerPage(onScan: _saveAccessId),
      ),
    );
  }

  Future<void> _saveAccessId(String scannedCode) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    if (scannedCode.isEmpty) return;

    final user = auth.currentUser;
    if (user == null) return;

    try {
      var accessIdDoc = await firestore.collection('access_ids').doc(scannedCode).get();

      if (accessIdDoc.exists) {
        await firestore.collection('users').doc(user.uid).update({
          'access_ids': FieldValue.arrayUnion([scannedCode])
        });
        showSuccessToast(context: context, title: 'Access ID Connected', message: 'You have successfully connected the Access ID: $scannedCode}');
        context.read<InventoryBloc>().add(LoadInventory());
      } else {
        showErrorToast(context: context, title: 'An Error Has Occured', message: 'Invalid Access ID');
      }
    } catch (e) {
      showErrorToast(context: context, title: 'An Error Has Occured', message: 'Error saving Access ID');
    }
  }

  void _showQrDialog(String accessId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("QR Code"),
        content: SizedBox(
          width: 240, // Set a fixed width
          height: 240, // Set a fixed height
          child: Center(
            child: QrImageView(
              data: accessId,
              version: QrVersions.auto,
              size: 500.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSection<T>(
      BuildContext context, {
        required String title,
        required List<T> items,
        required Function(T) onEdit,
        required Function(T) onDelete,
        required VoidCallback onAdd,
      }) {
    final localization = LocalizationService.of(context)!; // Get the localization instance
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemName = (item is ItemCategory)
                    ? item.name
                    : (item is Location)
                    ? item.name
                    : (item as Sublocation?)?.name ?? 'Unnamed';
                return Card(
                  elevation: 0,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 16),
                    title: Text(itemName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEdit(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmationDialog(context, item, onDelete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdd,
                child: Text('${localization.translate('add_new')} $title'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog<T>(BuildContext context, T item, Function(T) onDelete) {
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
              onDelete(item);
              Navigator.pop(context);
            },
            child: Text(localization.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _showAddModal({
    required BuildContext context,
    required String title,
    List<Location>? locations,
    required List<AccessId> accessIds,
    required bool isCategory,
    required bool isAccessId,
  }) {
    log((locations != null).toString());
    final controller = TextEditingController();
    Location? selectedLocation;
    AccessId? selectedAccessId = accessIds.first;
    final localization = LocalizationService.of(context)!; // Get the localization instance

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAccessId) AccessIdDropdown(
              accessIds: accessIds,
              selectedAccessId: selectedAccessId,
              onChanged: (value) {
                setState(() {
                  selectedAccessId = value;
                });
              },
            ),
            if (!isAccessId) const SizedBox(height: 16),
            if (locations != null)
              LocationDropdown(
                selectedAccessId: selectedAccessId,
                locations: locations,
                selectedLocation: selectedLocation,
                disableToAdd: false,
                onChanged: (value) {
                  selectedLocation = value;
                },
              ),
            if (locations != null) const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: LocalizationService.of(context)!.translate('name'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    if (isAccessId) {
                      context.read<InventoryBloc>().add(AddAccessId(controller.text));
                    } else {
                      if (isCategory) {
                        context.read<InventoryBloc>().add(AddCategory(controller.text, selectedAccessId!.id));
                      } else if (selectedLocation != null) {
                        context.read<InventoryBloc>().add(AddSublocation(
                            selectedLocation!.id,
                            controller.text,
                            selectedAccessId!.id
                        ));
                      } else {
                        context.read<InventoryBloc>().add(AddLocation(controller.text, selectedAccessId!.id));
                      }
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(localization.translate('add')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, dynamic item, String title, {required bool isCategory}) {
    final controller = TextEditingController(text: item.name);
    final localization = LocalizationService.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    if (isCategory) {
                      context.read<InventoryBloc>().add(EditCategory(
                        item.id,
                        controller.text,
                        item.accessId,
                      ));
                    } else if (item is Location) {
                      context.read<InventoryBloc>().add(EditLocation(
                        item.id,
                        controller.text,
                        item.accessId,
                      ));
                    } else if (item is Sublocation) {
                      context.read<InventoryBloc>().add(EditSublocation(
                        item.id,
                        controller.text,
                        item.accessId,
                      ));
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(localization.translate('update')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(BuildContext context, ItemCategory category) {
    context.read<InventoryBloc>().add(DeleteCategory(category.id));
  }

  void _deleteLocation(BuildContext context, Location location) {
    context.read<InventoryBloc>().add(DeleteLocation(location.id));
  }

  void _deleteSublocation(BuildContext context, Sublocation sublocation) {
    context.read<InventoryBloc>().add(DeleteSublocation(sublocation.id));
  }
}
