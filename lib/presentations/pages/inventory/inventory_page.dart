import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? selectedFilterType;
  String? selectedFilterValue;
  String? searchText = '';
  bool groupBy = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inventory",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/addedit').whenComplete(loadData);
            },
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventoryLoaded) {
            var items = state.items;

            // Apply filters
            if (searchText != null && searchText!.isNotEmpty) {
              items = items
                  .where((item) => item.name.toLowerCase().contains(searchText!.toLowerCase()))
                  .toList();
            }
            if (selectedFilterType != null && selectedFilterValue != null) {
              items = items.where((item) {
                switch (selectedFilterType) {
                  case 'Category':
                    return item.category == selectedFilterValue;
                  case 'Location':
                    return item.location == selectedFilterValue;
                  case 'Sublocation':
                    return item.sublocation == selectedFilterValue;
                  default:
                    return true;
                }
              }).toList();
            }

            // Group items if grouping is enabled
            Map<String, List<dynamic>> groupedItems = {};
            if (groupBy && selectedFilterType != null) {
              for (var item in items) {
                final key = selectedFilterType == 'Category'
                    ? item.category
                    : selectedFilterType == 'Location'
                    ? item.location ?? 'Unspecified'
                    : item.sublocation ?? 'Unspecified';
                groupedItems.putIfAbsent(key, () => []).add(item);
              }
            }

            return Column(
              children: [
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search inventory',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              DropdownButton<String>(
                                value: selectedFilterType,
                                hint: const Text('Filter by'),
                                items: const [
                                  DropdownMenuItem(value: 'Category', child: Text('Category')),
                                  DropdownMenuItem(value: 'Location', child: Text('Location')),
                                  DropdownMenuItem(value: 'Sublocation', child: Text('Sublocation')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedFilterType = value;
                                    selectedFilterValue = null; // Reset value
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              if (selectedFilterType != null)
                                DropdownButton<String>(
                                  value: selectedFilterValue,
                                  hint: Text('Select $selectedFilterType'),
                                  items: (selectedFilterType == 'Category'
                                      ? state.items.map((item) => item.category).toSet()
                                      : selectedFilterType == 'Location'
                                      ? state.items
                                      .map((item) => item.location)
                                      .where((loc) => loc != null)
                                      .toSet()
                                      : state.items
                                      .map((item) => item.sublocation)
                                      .where((subloc) => subloc != null)
                                      .toSet())
                                      .map((value) => DropdownMenuItem(value: value, child: Text(value!)))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFilterValue = value;
                                    });
                                  },
                                ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                groupBy = !groupBy;
                              });
                            },
                            icon: Icon(
                              groupBy ? Icons.view_list : Icons.group,
                              color: groupBy ? AppTheme.primaryColor : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Item List Section
                Expanded(
                  child: groupBy && groupedItems.isNotEmpty
                      ? ListView(
                    children: groupedItems.entries.map((entry) {
                      final group = entry.key;
                      final groupItems = entry.value;
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(group, style: const TextStyle(fontWeight: FontWeight.bold)),
                          children: groupItems.map((item) => _buildItemTile(context, item)).toList(),
                        ),
                      );
                    }).toList(),
                  )
                      : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildItemTile(context, item);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("Something went wrong."));
        },
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.grey.shade100,
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/addedit',
            arguments: {
              'id': item.id,
              'data': item.toMap(),
            },
          ).whenComplete(loadData);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Text(
                item.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            Text("Category: ${item.category}", style: const TextStyle(fontSize: 14)),
            if (item.location != null && item.location!.isNotEmpty)
              Text("Location: ${item.location}", style: const TextStyle(fontSize: 14)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}