import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/item/item_bloc.dart';
import 'package:kokiku/presentations/widgets/location_dropdown.dart';

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
    context.read<ItemBloc>().add(LoadItemPage());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!; // Get the localization instance

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('inventory_settings')),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          tabs: [
            Tab(text: localization.translate('categories')),
            Tab(text: localization.translate('locations')),
            Tab(text: localization.translate('sublocations')),
          ],
        ),
      ),
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<ItemBloc, ItemState>(
          builder: (context, state) {
            if (state is ItemLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ItemLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  // Category Section
                  _buildSection(
                    context,
                    title: localization.translate('categories'),
                    items: state.categories,
                    onEdit: (item) => _showEditModal(context, item, localization.translate('edit_category'), isCategory: true),
                    onDelete: (item) => _deleteCategory(context, item),
                    onAdd: () => _showAddModal(context: context, title: localization.translate('add_new_category'), isCategory: true),
                  ),
                  // Location Section
                  _buildSection(
                    context,
                    title: localization.translate('locations'),
                    items: state.locations,
                    onEdit: (item) => _showEditModal(context, item, localization.translate('edit_location'), isCategory: false),
                    onDelete: (item) => _deleteLocation(context, item),
                    onAdd: () => _showAddModal(context: context, title: localization.translate('add_new_location'), isCategory: false),
                  ),
                  // Sublocation Section
                  _buildSection(
                    context,
                    title: localization.translate('sublocations'),
                    items: state.sublocations,
                    onEdit: (item) => _showEditModal(context, item, localization.translate('edit_sublocation'), isCategory: false),
                    onDelete: (item) => _deleteSublocation(context, item),
                    onAdd: () => _showAddModal(context: context, title: localization.translate('add_new_sublocation'), locations: state.locations, isCategory: false),
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
              physics: const NeverScrollableScrollPhysics(),
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
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
    required bool isCategory,
  }) {
    final controller = TextEditingController();
    Location? selectedLocation;
    final localization = LocalizationService.of(context)!; // Get the localization instance

    showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (locations != null)
              LocationDropdown(
                locations: locations,
                selectedLocation: selectedLocation,
                disableToAdd: false,
                onChanged: (value) {
                  selectedLocation = value;
                },
              ),
            const SizedBox(height: 16),
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    if (isCategory) {
                      context.read<ItemBloc>().add(AddCategory(controller.text));
                    } else if (selectedLocation != null) {
                      context.read<ItemBloc>().add(AddSublocation(
                        selectedLocation!.id,
                        controller.text,
                      ));
                    } else {
                      context.read<ItemBloc>().add(AddLocation(controller.text));
                    }
                    Navigator.pop(context);
                  }
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
    final localization = LocalizationService.of(context)!; // Get the localization instance

    showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  if (isCategory) {
                    context.read<ItemBloc>().add(EditCategory(
                      item.id,
                      controller.text,
                    ));
                  } else if (item is Location) {
                    context.read<ItemBloc>().add(EditLocation(
                      item.id,
                      controller.text,
                    ));
                  } else if (item is Sublocation) {
                    context.read<ItemBloc>().add(EditSublocation(
                      item.id,
                      controller.text,
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(localization.translate('update')),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(BuildContext context, ItemCategory category) {
    context.read<ItemBloc>().add(DeleteCategory(category.id));
  }

  void _deleteLocation(BuildContext context, Location location) {
    context.read<ItemBloc>().add(DeleteLocation(location.id));
  }

  void _deleteSublocation(BuildContext context, Sublocation sublocation) {
    context.read<ItemBloc>().add(DeleteSublocation(sublocation.id));
  }
}
