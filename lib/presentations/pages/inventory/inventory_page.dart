import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/pages/inventory/add_edit_item_page.dart';

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

  Map<String, String> categoryTitles = {};
  Map<String, String> locationTitles = {};
  Map<String, String> sublocationTitles = {};

  List<ItemCategory> categories = [];
  List<Location> locations = [];
  List<Sublocation> sublocations = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadData() {
    context.read<InventoryBloc>().add(LoadInventory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/inventorysettings').whenComplete(loadData);
            },
            icon: const Icon(Icons.menu),
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

            // Centralize the mapping of IDs to Titles (only do this once)
            categoryTitles = state.categories.asMap().map((index, category) => MapEntry(category.id, category.name));
            categories = state.categories;
            locationTitles = state.locations.asMap().map((index, location) => MapEntry(location.id, location.name));
            locations = state.locations;
            sublocationTitles = state.sublocations.asMap().map((index, sublocation) => MapEntry(sublocation.id, sublocation.name));
            sublocations = state.sublocations;

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
                    return item.categoryId == selectedFilterValue;
                  case 'Location':
                    return item.locationId == selectedFilterValue;
                  case 'Sublocation':
                    return item.sublocationId == selectedFilterValue;
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
                    ? item.categoryId
                    : selectedFilterType == 'Location'
                    ? item.locationId ?? 'Unspecified'
                    : item.sublocationId ?? 'Unspecified';
                groupedItems.putIfAbsent(key!, () => []).add(item);
              }
            }

            return Column(
              children: [
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardTheme.color
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
                                      ? state.items.map((item) => item.categoryId).toSet()
                                      : selectedFilterType == 'Location'
                                      ? state.items
                                      .map((item) => item.locationId)
                                      .where((loc) => loc != null)
                                      .toSet()
                                      : state.items
                                      .map((item) => item.sublocationId)
                                      .where((subloc) => subloc != null)
                                      .toSet())
                                      .map((value) {
                                    String? displayValue;

                                    // Map IDs to Titles using the pre-defined maps
                                    if (selectedFilterType == 'Category') {
                                      displayValue = categoryTitles[value];
                                    } else if (selectedFilterType == 'Location') {
                                      displayValue = locationTitles[value];
                                    } else if (selectedFilterType == 'Sublocation') {
                                      displayValue = sublocationTitles[value];
                                    }

                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(displayValue ?? 'Unknown'),
                                    );
                                  }).toList(),
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
                      String groupTitle = '';

                      // Map group IDs to Titles using the pre-defined maps
                      if (selectedFilterType == 'Category') {
                        groupTitle = categoryTitles[group] ?? 'Unknown Category';
                      } else if (selectedFilterType == 'Location') {
                        groupTitle = locationTitles[group] ?? 'Unknown Location';
                      } else if (selectedFilterType == 'Sublocation') {
                        groupTitle = sublocationTitles[group] ?? 'Unknown Sublocation';
                      }

                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(groupTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          children: groupItems.map((item) => _buildItemTile(context, item)).toList(),
                        ),
                      );
                    }).toList(),
                  )
                      : items.isNotEmpty ? ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildItemTile(context, item);
                    },
                  ) : Center(
                    child: Text(
                      "You haven't added anything."
                    ),
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

  Widget _buildItemTile(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditItemPage(
                item: item,
                categories: categories,
                locations: locations,
                sublocations: sublocations,
              ))
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
                style: const TextStyle(fontSize: 14),
              ),
            Text(
              "Category: ${categoryTitles[item.categoryId] ?? 'Unknown'}",
              style: const TextStyle(fontSize: 14),
            ),
            if (item.locationId != null && item.locationId!.isNotEmpty)
              Text(
                "Location: ${locationTitles[item.locationId] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 14),
              ),
            if (item.sublocationId != null && item.sublocationId!.isNotEmpty)
              Text(
                "Sublocation: ${sublocationTitles[item.sublocationId] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}