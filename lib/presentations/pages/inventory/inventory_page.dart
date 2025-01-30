import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/category.dart';
import 'package:kokiku/datas/models/remote/inventory_item.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/pages/inventory/add_edit_item_page.dart';
import 'package:kokiku/presentations/widgets/access_id_input.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  List<AccessId> accessIds = [];
  List<ItemCategory> categories = [];
  List<Location> locations = [];
  List<Sublocation> sublocations = [];

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
    final localization = LocalizationService.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('inventory')),
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
            return _buildSkeletonLoader();
          }

          if (state is InventoryLoaded) {
            var items = state.inventoryItems;

            // Centralized mapping of titles
            Map<String, String> accessIdTitles = _mapTitles(state.accessIds);
            accessIds = state.accessIds;
            Map<String, String> categoryTitles = _mapTitles(state.categories);
            categories = state.categories;
            Map<String, String> locationTitles = _mapTitles(state.locations);
            locations = state.locations;
            Map<String, String> sublocationTitles = _mapTitles(state.sublocations);
            sublocations = state.sublocations;

            // Filter logic
            items = _applyFilters(items, state);

            // Group items if grouping is enabled
            var groupedItems = groupBy ? _groupItems(items) : {};

            return Column(
              children: [
                _buildSearchAndFilterSection(state),
                Expanded(
                  child: groupBy && groupedItems.isNotEmpty
                      ? ListView(
                    children: groupedItems.entries.map((entry) {
                      final group = entry.key;
                      final groupItems = entry.value;
                      String groupTitle = _getGroupTitle(group, accessIdTitles, categoryTitles, locationTitles, sublocationTitles);

                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          backgroundColor: Theme.of(context).cardTheme.color,
                          collapsedBackgroundColor: Theme.of(context).cardTheme.color,
                          title: Text(groupTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          children: groupItems.map<Widget>((item) => _buildItemTile(context, item, accessIdTitles, categoryTitles, locationTitles, sublocationTitles)).toList(),
                        ),
                      );
                    }).toList(),
                  )
                      : items.isNotEmpty
                      ? ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildItemTile(context, items[index], accessIdTitles, categoryTitles, locationTitles, sublocationTitles);
                    },
                  )
                      : Center(
                    child: Text(localization.translate('no_items')),
                  ),
                ),
              ],
            );
          }

          if (state is InventoryNoAccessIds) {
            return Center(
              child: AccessIdInput(),
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    Map<String,String> empty = _mapTitles([]);
    InventoryItem item = InventoryItem(id: '', name: '', quantity: 1, accessId: '');
    return Column(
      children: [
        _buildSearchAndFilterSection(InventoryLoaded(
          accessIds: [],
          categories: [],
          locations: [],
          sublocations: [],
          inventoryItems: [],
        )),
        Expanded(
          child: groupBy
              ? ListView(
            children: [].map((entry) {
              final group = entry.key;
              final groupItems = entry.value;
              String groupTitle = _getGroupTitle(group, empty, empty, empty, empty);

              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(groupTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: groupItems.map<Widget>((item) => _buildItemTile(context, item, empty, empty, empty, empty)).toList(),
                ),
              );
            }).toList(),
          )
              : Skeletonizer(
                child: ListView.builder(
                            itemCount: 4,
                            itemBuilder: (context, index) {
                return _buildItemTile(context, item, empty, empty, empty, empty);
                            },
                          ),
              ),
        ),
      ],
    );
  }

  Map<String, String> _mapTitles<T>(List<T> items) {
    return { for (var item in items) (item as dynamic).id : item.name };
  }

  List<InventoryItem> _applyFilters(List<InventoryItem> items, InventoryLoaded state) {
    if (searchText != null && searchText!.isNotEmpty) {
      items = items.where((item) => item.name.toLowerCase().contains(searchText!.toLowerCase())).toList();
    }

    if (selectedFilterType != null && selectedFilterValue != null) {
      items = items.where((item) {
        switch (selectedFilterType) {
          case 'Access Id':
            return item.accessId == selectedFilterValue;
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
    return items;
  }

  Map<String, List<InventoryItem>> _groupItems(List<InventoryItem> items) {
    Map<String, List<InventoryItem>> groupedItems = {};
    for (var item in items) {
      final key = selectedFilterType == 'Access Id'
          ? item.accessId
          : selectedFilterType == 'Category'
          ? item.categoryId
          : selectedFilterType == 'Location'
          ? item.locationId ?? 'Unspecified'
          : item.sublocationId ?? 'Unspecified';
      groupedItems.putIfAbsent(key!, () => []).add(item);
    }
    return groupedItems;
  }

  String _getGroupTitle(String group, Map<String, String> accessIdTitles, Map<String, String> categoryTitles, Map<String, String> locationTitles, Map<String, String> sublocationTitles) {
    final localization = LocalizationService.of(context)!;
    switch (selectedFilterType) {
      case 'Access Id':
        return accessIdTitles[group] ?? localization.translate('uknown_access_id');
      case 'Category':
        return categoryTitles[group] ?? localization.translate('unknown_category');
      case 'Location':
        return locationTitles[group] ?? localization.translate('unknown_location');
      case 'Sublocation':
        return sublocationTitles[group] ?? localization.translate('unknown_sublocation');
      default:
        return 'Unknown';
    }
  }

  Widget _buildItemTile(BuildContext context, InventoryItem item, Map<String, String> accessIdTitles, Map<String, String> categoryTitles, Map<String, String> locationTitles, Map<String, String> sublocationTitles) {
    final localization = LocalizationService.of(context)!;
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
              accessIds: accessIds,
              categories: categories,
              locations: locations,
              sublocations: sublocations,
            ))).whenComplete(loadData);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Text(item.description!),
            Text(
              "${localization.translate('category')}: ${categoryTitles[item.categoryId] ?? localization.translate('unknown')}",
            ),
            if (item.locationId != null && item.locationId!.isNotEmpty)
              Text(
                "${localization.translate('location')}: ${locationTitles[item.locationId] ?? localization.translate('unknown')}",
              ),
            if (item.sublocationId != null && item.sublocationId!.isNotEmpty)
              Text(
                "${localization.translate('sublocation')}: ${sublocationTitles[item.sublocationId] ?? localization.translate('unknown')}",
              ),
            if (item.expDate != null)
              Text(
                "${localization.translate('exp_date')}: ${timestamptToString(item.expDate!)}",
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(InventoryLoaded state) {
    final localization = LocalizationService.of(context)!;
    return Container(
      color: Theme.of(context).cardTheme.color,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardTheme.color,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: localization.translate('search_inventory'),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    hint: Text(localization.translate('filter_by')),
                    items: const [
                      DropdownMenuItem(value: 'Access Id', child: Text('Access Id')),
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
                      hint: Text('${localization.translate('select')} $selectedFilterType'),
                      items: _getFilterItems(state),
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
    );
  }

  List<DropdownMenuItem<String>> _getFilterItems(InventoryLoaded state) {
    Set<String?> filterItems = {};

    if (selectedFilterType == 'Access Id') {
      filterItems = state.accessIds.map((access) => access.id).toSet();
    } else if (selectedFilterType == 'Category') {
      filterItems = state.categories.map((category) => category.id).toSet();
    } else if (selectedFilterType == 'Location') {
      filterItems = state.locations.map((location) => location.id).toSet();
    } else if (selectedFilterType == 'Sublocation') {
      filterItems = state.sublocations.map((sublocation) => sublocation.id).toSet();
    }

    return filterItems.map((value) {
      String title = '';
      if (selectedFilterType == 'Access Id') {
        title = state.accessIds.firstWhere((access) => access.id == value).name ?? 'Unknown';
      } else if (selectedFilterType == 'Category') {
        title = state.categories.firstWhere((category) => category.id == value).name ?? 'Unknown';
      } else if (selectedFilterType == 'Location') {
        title = state.locations.firstWhere((location) => location.id == value).name ?? 'Unknown';
      } else if (selectedFilterType == 'Sublocation') {
        title = state.sublocations.firstWhere((sublocation) => sublocation.id == value).name ?? 'Unknown';
      }
      return DropdownMenuItem(value: value, child: Text(title));
    }).toList();
  }

  String timestamptToString(Timestamp timestamp) {
    return DateFormat('dd MMMM yyyy').format(timestamp.toDate());
  }
}
