import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Settings'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Locations'),
            Tab(text: 'Sublocations'),
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
                    title: 'Categories',
                    items: state.categories,
                    onEdit: (item) => _showEditModal(context, item, 'Edit Category', isCategory: true),
                    onDelete: (item) => _deleteCategory(context, item),
                    onAdd: () => _showAddModal(context: context, title: 'Add New Category', isCategory: true),
                  ),
                  // Location Section
                  _buildSection(
                    context,
                    title: 'Locations',
                    items: state.locations,
                    onEdit: (item) => _showEditModal(context, item, 'Edit Location', isCategory: false),
                    onDelete: (item) => _deleteLocation(context, item),
                    onAdd: () => _showAddModal(context: context, title: 'Add New Location', isCategory: false),
                  ),
                  // Sublocation Section
                  _buildSection(
                    context,
                    title: 'Sublocations',
                    items: state.sublocations,
                    onEdit: (item) => _showEditModal(context, item, 'Edit Sublocation', isCategory: false),
                    onDelete: (item) => _deleteSublocation(context, item),
                    onAdd: () => _showAddModal(context: context, title: 'Add New Sublocation', locations: state.locations, isCategory: false),
                  ),
                ],
              );
            }

            return const Center(child: Text('Error loading inventory settings.'));
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
                return ListTile(
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
                child: Text('Add New $title'),
              ),
            ),
          )
        ],
      )
    );
  }

  void _showDeleteConfirmationDialog<T>(BuildContext context, T item, Function(T) onDelete) {
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
            onPressed: () {
              onDelete(item);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddModal({
    required BuildContext context,
    required String title,
    List<Location>? locations,
    required bool isCategory, // Determines if it's for a category, location, or sublocation
  }) {
    final controller = TextEditingController();
    Location? selectedLocation;

    showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (locations != null)
              LocationDropdown(
                locations: locations,
                selectedLocation: selectedLocation,
                disableToAdd: false,
                onChanged: (value) {
                  selectedLocation = value;
                },
              ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, dynamic item, String title, {required bool isCategory}) {
    final controller = TextEditingController(text: item.name);

    showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
              child: const Text('Update'),
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
