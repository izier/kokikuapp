import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/item/item_bloc.dart';

class InventorySettingsPage extends StatelessWidget {
  const InventorySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Settings'),
      ),
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ItemBloc, ItemState>(
          builder: (context, state) {
            if (state is ItemLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ItemLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Section
                    _buildSectionTitle('Categories'),
                    _buildItemList<ItemCategory>(
                      items: state.categories,
                      onEdit: (item) => _showEditCategoryModal(context, item),
                      onDelete: (item) => _deleteCategory(context, item),
                      onAdd: () => _showAddCategoryModal(context),
                    ),
                    const SizedBox(height: 16),

                    // Location Section
                    _buildSectionTitle('Locations'),
                    _buildItemList<Location>(
                      items: state.locations,
                      onEdit: (item) => _showEditLocationModal(context, item),
                      onDelete: (item) => _deleteLocation(context, item),
                      onAdd: () => _showAddLocationModal(context),
                    ),
                    const SizedBox(height: 16),

                    // Sublocation Section
                    _buildSectionTitle('Sublocations'),
                    _buildItemList<Sublocation>(
                      items: state.sublocations,
                      onEdit: (item) => _showEditSublocationModal(context, item),
                      onDelete: (item) => _deleteSublocation(context, item),
                      onAdd: () => _showAddSublocationModal(context),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Error loading settings.'));
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildItemList<T>({
    required List<T> items,
    required Function(T) onEdit,
    required Function(T) onDelete,
    required VoidCallback onAdd,
  }) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item is ItemCategory ? item.name : item is Location ? item.name : (item as Sublocation).name),
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
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add New'),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog<T>(BuildContext context, T item, Function(T) onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDelete(item);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
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

  void _showAddCategoryModal(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Category', style: TextStyle(fontSize: 18)),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                context.read<ItemBloc>().add(AddCategory(controller.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationModal(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Location', style: TextStyle(fontSize: 18)),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                context.read<ItemBloc>().add(AddLocation(controller.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSublocationModal(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Sublocation', style: TextStyle(fontSize: 18)),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                context.read<ItemBloc>().add(AddSublocation('-',controller.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryModal(BuildContext context, ItemCategory category) {
    final controller = TextEditingController(text: category.name);

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Category', style: TextStyle(fontSize: 18)),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                context.read<ItemBloc>().add(EditCategory(category.id, controller.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLocationModal(BuildContext context, Location location) {
    final controller = TextEditingController(text: location.name);

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Location', style: TextStyle(fontSize: 18)),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                context.read<ItemBloc>().add(EditLocation(location.id, controller.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSublocationModal(BuildContext context, Sublocation sublocation) {
    final controller = TextEditingController(text: sublocation.name);

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Sublocation', style: TextStyle(fontSize: 18)),
            TextField(controller: controller),
            ElevatedButton(
              onPressed: () {
                context.read<ItemBloc>().add(EditSublocation(sublocation.id, controller.text.trim()));
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
